#!/usr/bin/env bash
# Run the job-applier pipeline (skills 1–4) for several companies concurrently,
# then export each finished resume to PDF (serially, since headless Chrome
# doesn't like parallel runs).
#
# Each company runs ./scripts/run-pipeline.sh in the background. If any Claude
# session hits a plan usage limit, it sleeps until the reset time and then
# resumes that same session where it left off; the other companies see the
# shared pause and hold off too, instead of each burning a request on the limit.
#
# Prerequisites:
#   - `claude` CLI installed and authenticated
#   - /0-setup-resume has been run
#   - applications/<company>/job-description.md exists for every company
#
# Usage:
#   ./scripts/run-batch.sh <company-kebab> [<company-kebab> ...] [options]
#   ./scripts/run-batch.sh --file <list.txt> [options]
#
# Options:
#   --file PATH                One company kebab name per line (# comments and
#                              blank lines ignored); may be combined with names
#   --jobs N                   Max companies running at once (default: all)
#   --from-step N              Passed to run-pipeline.sh
#   --model MODEL              Passed to run-pipeline.sh
#   --permission-mode MODE     Passed to run-pipeline.sh
#   --max-limit-wait HOURS     Passed to run-pipeline.sh
#   --dry-run                  Passed to run-pipeline.sh (no agents, no PDFs)
#   -h, --help                 Show this help
#
# Output:
#   Console lines are prefixed with [company]. Full per-company output goes to
#   pipeline-batches/<timestamp>/<company>.log; each step's detailed logs stay
#   under applications/<company>/pipeline-logs/ as with run-pipeline.sh.
#
# Examples:
#   ./scripts/run-batch.sh acme-corp globex initech
#   ./scripts/run-batch.sh --file jobs.txt --jobs 3
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PIPELINE="${SCRIPT_DIR}/run-pipeline.sh"
TO_PDF="${SCRIPT_DIR}/to-pdf.sh"

COMPANIES=()
PASSTHROUGH=()
JOBS=0
DRY_RUN=0

usage() {
    awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$0"
}

die() {
    echo "error: $*" >&2
    exit 1
}

add_companies_from_file() {
    local path="$1"
    local line

    [[ -f "${path}" ]] || die "company list not found: ${path}"
    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%%#*}"
        line="$(printf '%s' "${line}" | tr -d '[:space:]')"
        [[ -n "${line}" ]] && COMPANIES+=("${line}")
    done < "${path}"
}

parse_args() {
    [[ $# -ge 1 ]] || { usage >&2; exit 2; }

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --file)
                [[ $# -ge 2 ]] || die "--file requires a path"
                add_companies_from_file "$2"
                shift 2
                ;;
            --jobs)
                [[ $# -ge 2 ]] || die "--jobs requires a value"
                JOBS="$2"
                [[ "${JOBS}" =~ ^[0-9]+$ ]] || die "--jobs must be a whole number"
                shift 2
                ;;
            --from-step|--model|--permission-mode|--max-limit-wait)
                [[ $# -ge 2 ]] || die "$1 requires a value"
                PASSTHROUGH+=("$1" "$2")
                shift 2
                ;;
            --dry-run)
                DRY_RUN=1
                PASSTHROUGH+=("$1")
                shift
                ;;
            --*)
                die "unknown option: $1"
                ;;
            *)
                COMPANIES+=("$1")
                shift
                ;;
        esac
    done

    [[ "${#COMPANIES[@]}" -gt 0 ]] || die "no companies given"
}

# Fail fast (before starting anything) if any company is missing its JD or is listed twice.
validate_companies() {
    local company missing=() seen=" "

    for company in "${COMPANIES[@]}"; do
        case "${seen}" in
            *" ${company} "*) die "company listed twice: ${company}" ;;
        esac
        seen="${seen}${company} "
        [[ -f "${PROJECT_ROOT}/applications/${company}/job-description.md" ]] || missing+=("${company}")
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        echo "error: missing applications/<company>/job-description.md for:" >&2
        printf '  %s\n' "${missing[@]}" >&2
        exit 1
    fi
}

running_count() {
    local pid count=0
    for pid in ${PIDS[@]+"${PIDS[@]}"}; do
        kill -0 "${pid}" 2>/dev/null && count=$((count + 1))
    done
    echo "${count}"
}

start_company() {
    local company="$1"
    local log="${BATCH_DIR}/${company}.log"
    local status_file="${BATCH_DIR}/${company}.status"

    (
        set +e
        "${PIPELINE}" "${company}" --skip-pdf ${PASSTHROUGH[@]+"${PASSTHROUGH[@]}"} 2>&1 \
            | tee "${log}" \
            | sed -u "s/^/[${company}] /"
        echo "${PIPESTATUS[0]}" > "${status_file}"
    ) &
    PIDS+=("$!")
}

# Last "==> Step N" the pipeline started, for the failure summary.
last_step_started() {
    local log="$1"
    grep -oE '==> Step [1-4]' "${log}" 2>/dev/null | tail -n 1 | grep -oE '[1-4]$' || true
}

main() {
    parse_args "$@"
    validate_companies

    [[ -x "${PIPELINE}" ]] || die "run-pipeline.sh not found or not executable: ${PIPELINE}"

    local timestamp
    timestamp="$(date +"%Y%m%d-%H%M%S")"
    BATCH_DIR="${PROJECT_ROOT}/pipeline-batches/${timestamp}"
    mkdir -p "${BATCH_DIR}"
    export PIPELINE_LIMIT_FILE="${BATCH_DIR}/limit-until"
    PIDS=()

    # Ctrl-C / kill: take down every pipeline (and its claude sessions) with us.
    trap 'trap - INT TERM; echo; echo "Interrupted — stopping all pipelines..." >&2; kill 0; exit 130' INT TERM

    echo "Batch:     ${#COMPANIES[@]} companies — ${COMPANIES[*]}"
    if [[ "${JOBS}" -gt 0 ]]; then
        echo "Parallel:  up to ${JOBS} at a time"
    else
        echo "Parallel:  all at once"
    fi
    echo "Batch dir: ${BATCH_DIR#${PROJECT_ROOT}/}"
    echo

    local company
    for company in "${COMPANIES[@]}"; do
        if [[ "${JOBS}" -gt 0 ]]; then
            while [[ "$(running_count)" -ge "${JOBS}" ]]; do
                sleep 5
            done
        fi
        echo "[batch] starting ${company}"
        start_company "${company}"
    done

    wait

    echo
    local status succeeded=() failed=()
    for company in "${COMPANIES[@]}"; do
        status="$(cat "${BATCH_DIR}/${company}.status" 2>/dev/null || echo 1)"
        if [[ "${status}" -eq 0 ]]; then
            succeeded+=("${company}")
        else
            failed+=("${company}")
        fi
    done

    if [[ "${#succeeded[@]}" -gt 0 ]]; then
        echo "==> PDF export"
        for company in "${succeeded[@]}"; do
            if [[ "${DRY_RUN}" -eq 1 ]]; then
                echo "    [dry-run] ${TO_PDF} ${company}"
            elif ! "${TO_PDF}" "${company}" 2>&1 | sed -u "s/^/[${company}] /"; then
                echo "[${company}] PDF export failed"
                failed+=("${company}")
            fi
        done
        echo
    fi

    echo "==> Summary"
    local step pdf_failed
    for company in "${COMPANIES[@]}"; do
        status="$(cat "${BATCH_DIR}/${company}.status" 2>/dev/null || echo 1)"
        pdf_failed=0
        [[ " ${failed[*]-} " == *" ${company} "* && "${status}" -eq 0 ]] && pdf_failed=1
        if [[ "${status}" -eq 0 && "${pdf_failed}" -eq 0 ]]; then
            printf '  ✓ %-28s done\n' "${company}"
        elif [[ "${pdf_failed}" -eq 1 ]]; then
            printf '  ✗ %-28s pipeline ok, PDF export failed\n' "${company}"
        else
            step="$(last_step_started "${BATCH_DIR}/${company}.log")"
            printf '  ✗ %-28s failed at step %s — see %s\n' "${company}" "${step:-?}" \
                "${BATCH_DIR#${PROJECT_ROOT}/}/${company}.log"
        fi
    done

    [[ "${#failed[@]}" -eq 0 ]]
}

main "$@"
