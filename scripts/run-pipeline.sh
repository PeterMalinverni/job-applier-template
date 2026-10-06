#!/usr/bin/env bash
# Run the job-applier pipeline (skills 1–4) via the Claude Code CLI, then
# convert the tailored resume HTML to PDF.
#
# Each step runs in its own fresh Claude session so prior context does not
# leak between skills. Sessions are persisted (with a known session id) so a
# step interrupted by a usage limit can wait for the reset and then resume
# exactly where it left off instead of starting over.
#
# Prerequisites:
#   - `claude` CLI installed and authenticated
#   - /0-setup-resume has been run (inputs/resume_full.html, inputs/profile.md)
#   - applications/<company>/job-description.md exists
#     (./scripts/add-job.sh <company> creates it)
#
# Usage:
#   ./scripts/run-pipeline.sh <company-kebab> [options]
#
# Options:
#   --model MODEL              Model override for all steps (defaults:
#                              steps 1–3: claude-sonnet-5-5; step 4: claude-opus-5-5)
#   --from-step N              Start at step N (1–4); earlier outputs must exist
#   --permission-mode MODE     acceptEdits (default) or bypassPermissions
#   --skip-pdf                 Don't run the PDF export after step 4
#   --max-limit-wait HOURS     Give up on a step if usage-limit waits exceed
#                              HOURS in total (default: 0 = wait forever)
#   --dry-run                  Print commands without running the agent
#   -h, --help                 Show this help
#
# Environment:
#   PIPELINE_LIMIT_FILE        Shared pause file (set by run-batch.sh). When one
#                              session hits a usage limit it writes the reset
#                              time here; all others wait before calling claude.
#   USAGE_LIMIT_FALLBACK_WAIT  Seconds to wait when the reset time can't be
#                              parsed from Claude's message (default: 1800)
#
# Examples:
#   ./scripts/run-pipeline.sh acme-corp
#   ./scripts/run-pipeline.sh acme-corp --from-step 3
#   ./scripts/run-pipeline.sh acme-corp --model claude-opus-5-5 --permission-mode bypassPermissions
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

DEFAULT_CLAUDE_MODEL="claude-sonnet-5-5"
DEFAULT_CLAUDE_STEP4_MODEL="claude-opus-5-5"
DEFAULT_PERMISSION_MODE="acceptEdits"
CLAUDE_MAX_ATTEMPTS=3
USAGE_LIMIT_FALLBACK_WAIT="${USAGE_LIMIT_FALLBACK_WAIT:-1800}"
USAGE_LIMIT_BUFFER_SECONDS="${USAGE_LIMIT_BUFFER_SECONDS:-120}"
CLAUDE_CONTINUE_PROMPT="You were interrupted (usage limit or dropped connection). Continue the task exactly where you left off. Do not redo work already completed or rewrite files already written unless they are incomplete. When finished, give the same brief summary you would have given originally."

COMPANY=""
MODEL=""
MODEL_SET=0
FROM_STEP=1
PERMISSION_MODE="${DEFAULT_PERMISSION_MODE}"
DRY_RUN=0
SKIP_PDF=0
MAX_LIMIT_WAIT_HOURS=0

usage() {
    # Print the leading comment block (everything after the shebang up to the first non-comment line).
    awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$0"
}

die() {
    echo "error: $*" >&2
    exit 1
}

require_file() {
    local path="$1"
    local hint="$2"
    [[ -f "${path}" ]] || die "missing ${path#${PROJECT_ROOT}/} — ${hint}"
}

ensure_claude_skills() {
    local skill
    for skill in 1-ats-keywords 2-rubric 3-fit-assessment 4-optimize-resume common; do
        [[ -d "${PROJECT_ROOT}/.claude/skills/${skill}" ]] \
            || die "skill not found: .claude/skills/${skill}"
    done
}

parse_args() {
    if [[ $# -lt 1 ]]; then
        usage >&2
        exit 2
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --model)
                [[ $# -ge 2 ]] || die "--model requires a value"
                MODEL="$2"
                MODEL_SET=1
                shift 2
                ;;
            --from-step)
                [[ $# -ge 2 ]] || die "--from-step requires a value (1–4)"
                FROM_STEP="$2"
                shift 2
                ;;
            --permission-mode)
                [[ $# -ge 2 ]] || die "--permission-mode requires a value"
                PERMISSION_MODE="$2"
                shift 2
                ;;
            --skip-pdf)
                SKIP_PDF=1
                shift
                ;;
            --max-limit-wait)
                [[ $# -ge 2 ]] || die "--max-limit-wait requires a value (hours)"
                MAX_LIMIT_WAIT_HOURS="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            --*)
                die "unknown option: $1"
                ;;
            *)
                [[ -z "${COMPANY}" ]] || die "unexpected extra argument: $1"
                COMPANY="$1"
                shift
                ;;
        esac
    done

    [[ -n "${COMPANY}" ]] || die "company kebab name is required"
    [[ "${FROM_STEP}" =~ ^[1-4]$ ]] || die "--from-step must be 1, 2, 3, or 4"
    [[ "${PERMISSION_MODE}" == "acceptEdits" || "${PERMISSION_MODE}" == "bypassPermissions" ]] \
        || die "--permission-mode must be acceptEdits or bypassPermissions"
    [[ "${MAX_LIMIT_WAIT_HOURS}" =~ ^[0-9]+$ ]] || die "--max-limit-wait must be a whole number of hours"

    if [[ "${MODEL_SET}" -eq 0 ]]; then
        MODEL="${DEFAULT_CLAUDE_MODEL}"
    fi
}

# Per-step model: Opus for step 4 unless --model overrides all steps.
model_for_step() {
    local step="$1"

    if [[ "${MODEL_SET}" -eq 1 ]]; then
        echo "${MODEL}"
        return
    fi

    if [[ "${step}" -eq 4 ]]; then
        echo "${DEFAULT_CLAUDE_STEP4_MODEL}"
    else
        echo "${DEFAULT_CLAUDE_MODEL}"
    fi
}

# Short prompt per step (slash skills resolve SKILL.md themselves).
step_prompt() {
    local step="$1"
    local company="$2"

    case "${step}" in
        1)
            cat <<EOF
/1-ats-keywords

The job description is already saved at applications/${company}/job-description.md.
Read that file and run the full /1-ats-keywords workflow.
Save all outputs under applications/${company}/.
Do not ask for the JD or company folder — use the paths above.
EOF
            ;;
        2)
            cat <<EOF
/2-rubric

Application folder: ${company}
Run the full /2-rubric workflow for this application.
Do not ask which folder to use.
EOF
            ;;
        3)
            cat <<EOF
/3-fit-assessment

Application folder: ${company}
Run the full /3-fit-assessment workflow for this application.
Do not ask which folder to use.

Critical: write the full assessment to applications/${company}/03-fit-assessment.md with the Write tool first.
In chat, return ONLY the brief summary (verdict + path). Do not paste the full report into chat — long streams disconnect.
EOF
            ;;
        4)
            cat <<EOF
/4-optimize-resume

Application folder: ${company}
Run the full /4-optimize-resume workflow for this application.
Do not ask which folder to use.
EOF
            ;;
        *)
            die "internal error: unknown step ${step}"
            ;;
    esac
}

expected_output_for_step() {
    local step="$1"
    local company="$2"

    case "${step}" in
        1) echo "${PROJECT_ROOT}/applications/${company}/01-ats-keywords.md" ;;
        2) echo "${PROJECT_ROOT}/applications/${company}/02-rubric.md" ;;
        3) echo "${PROJECT_ROOT}/applications/${company}/03-fit-assessment.md" ;;
        4) echo "${PROJECT_ROOT}/applications/${company}/04-tailoring-report.md" ;;
    esac
}

validate_prerequisites() {
    local company="$1"
    local step="$2"
    local app_dir="${PROJECT_ROOT}/applications/${company}"

    [[ -d "${app_dir}" ]] || die "application directory not found: applications/${company}"

    case "${step}" in
        1)
            require_file "${app_dir}/job-description.md" \
                "run ./scripts/add-job.sh ${company} first"
            ;;
        2)
            require_file "${app_dir}/job-description.md" "run step 1 first or add job-description.md"
            ;;
        3)
            require_file "${app_dir}/job-description.md" "run step 1 first or add job-description.md"
            require_file "${app_dir}/02-rubric.md" "run step 2 first"
            require_file "${PROJECT_ROOT}/inputs/resume_full.html" "run /0-setup-resume first"
            require_file "${PROJECT_ROOT}/inputs/profile.md" "run /0-setup-resume first"
            ;;
        4)
            require_file "${app_dir}/job-description.md" "run step 1 first or add job-description.md"
            require_file "${app_dir}/01-ats-keywords.md" "run step 1 first"
            require_file "${app_dir}/03-fit-assessment.md" "run step 3 first"
            require_file "${PROJECT_ROOT}/inputs/resume_full.html" "run /0-setup-resume first"
            require_file "${PROJECT_ROOT}/inputs/resume_full.css" "run /0-setup-resume first"
            require_file "${PROJECT_ROOT}/inputs/profile.md" "run /0-setup-resume first"
            ;;
    esac
}

is_transient_claude_failure() {
    local log_file="$1"
    [[ -f "${log_file}" ]] || return 1
    grep -qiE 'Connection closed mid-response|API Error:.*(timeout|overloaded|529|rate limit|ECONNRESET|socket hang up)|response above may be incomplete' "${log_file}"
}

# Plan usage limits (5-hour / weekly / model-specific), as printed by Claude Code, e.g.
#   "Claude AI usage limit reached|1759262400"
#   "5-hour limit reached ∙ resets 3pm"
#   "You've hit your limit · resets 3:30pm (America/New_York)"
is_usage_limit_failure() {
    local log_file="$1"
    [[ -f "${log_file}" ]] || return 1
    grep -qiE 'usage limit reached|hit your (usage )?limit|(session|5-hour|weekly|opus|sonnet) limit reached|limit reached.{0,8}resets' "${log_file}"
}

is_missing_session_failure() {
    local log_file="$1"
    [[ -f "${log_file}" ]] || return 1
    grep -qiE 'No conversation found|session .*not found' "${log_file}"
}

# `date` in timezone $1, or the local timezone when $1 is empty (TZ="" would mean UTC).
date_in_tz() {
    local tz="$1"
    shift
    if [[ -n "${tz}" ]]; then
        TZ="${tz}" date "$@"
    else
        date "$@"
    fi
}

# Epoch seconds when the usage limit resets, parsed from the Claude output; empty if unknown.
usage_limit_reset_epoch() {
    local log_file="$1"
    local epoch match tz time_str month_day hour minute ampm today year parsed now

    epoch="$(grep -oiE 'usage limit reached\|[0-9]{9,}' "${log_file}" | tail -n 1 | sed 's/.*|//')"
    if [[ -n "${epoch}" ]]; then
        echo "${epoch}"
        return 0
    fi

    match="$(grep -oiE 'resets (at )?([A-Z][a-z]{2} [0-9]{1,2},? (at )?)?[0-9]{1,2}(:[0-9]{2})? ?(am|pm)( \([^)]+\))?' "${log_file}" | tail -n 1)"
    [[ -n "${match}" ]] || return 0

    # Explicit "(America/New_York)" if given; otherwise the local timezone.
    tz="$(printf '%s' "${match}" | sed -nE 's/.*\(([^)]+)\).*/\1/p')"
    time_str="$(printf '%s' "${match}" | grep -oiE '[0-9]{1,2}(:[0-9]{2})? ?(am|pm)' | tail -n 1 | tr -d ' ')"
    month_day="$(printf '%s' "${match}" | grep -oE '[A-Z][a-z]{2} [0-9]{1,2}' | head -n 1)"

    hour="$(printf '%s' "${time_str}" | sed -E 's/^([0-9]+).*/\1/')"
    minute="$(printf '%s' "${time_str}" | sed -nE 's/^[0-9]+:([0-9]{2}).*/\1/p')"
    [[ -n "${minute}" ]] || minute="00"
    ampm="$(printf '%s' "${time_str}" | grep -oiE '(am|pm)$' | tr '[:lower:]' '[:upper:]')"

    now="$(date +%s)"
    if [[ -n "${month_day}" ]]; then
        year="$(date_in_tz "${tz}" +%Y)"
        parsed="$(date_in_tz "${tz}" -j -f "%b %d %Y %I:%M:%S%p" "${month_day} ${year} ${hour}:${minute}:00${ampm}" +%s 2>/dev/null || true)"
    else
        today="$(date_in_tz "${tz}" +%Y-%m-%d)"
        parsed="$(date_in_tz "${tz}" -j -f "%Y-%m-%d %I:%M:%S%p" "${today} ${hour}:${minute}:00${ampm}" +%s 2>/dev/null || true)"
        # "resets 2am" seen at 11pm means tomorrow.
        if [[ -n "${parsed}" && "${parsed}" -le "${now}" ]]; then
            parsed=$((parsed + 86400))
        fi
    fi
    [[ -n "${parsed}" ]] && echo "${parsed}"
    return 0
}

# Seconds to sleep before resuming after a usage limit.
usage_limit_wait_seconds() {
    local log_file="$1"
    local reset now wait

    now="$(date +%s)"
    reset="$(usage_limit_reset_epoch "${log_file}")"
    if [[ -n "${reset}" ]]; then
        wait=$((reset - now + USAGE_LIMIT_BUFFER_SECONDS))
    else
        wait="${USAGE_LIMIT_FALLBACK_WAIT}"
    fi
    [[ "${wait}" -ge 60 ]] || wait=60
    echo "${wait}"
}

# Tell other concurrent pipelines (run-batch.sh) to hold off until resume_at.
publish_shared_limit() {
    local resume_at="$1"
    local current

    [[ -n "${PIPELINE_LIMIT_FILE:-}" ]] || return 0
    current="$(cat "${PIPELINE_LIMIT_FILE}" 2>/dev/null || true)"
    if [[ ! "${current}" =~ ^[0-9]+$ || "${resume_at}" -gt "${current}" ]]; then
        echo "${resume_at}" > "${PIPELINE_LIMIT_FILE}"
    fi
}

# Sleep while another concurrent pipeline has reported a usage limit.
wait_for_shared_limit() {
    local resume_at now

    [[ -n "${PIPELINE_LIMIT_FILE:-}" && -f "${PIPELINE_LIMIT_FILE}" ]] || return 0
    resume_at="$(cat "${PIPELINE_LIMIT_FILE}" 2>/dev/null || true)"
    [[ "${resume_at}" =~ ^[0-9]+$ ]] || return 0
    now="$(date +%s)"
    if [[ "${resume_at}" -gt "${now}" ]]; then
        echo "    usage limit in effect (shared); waiting until $(date -r "${resume_at}" +"%a %H:%M")..."
        sleep $((resume_at - now))
    fi
}

new_session_id() {
    uuidgen | tr '[:upper:]' '[:lower:]'
}

# Runs one Claude session for a step. If it is interrupted — by a plan usage limit
# (wait for the reset, however long) or a transient API failure (short backoff) —
# the same session is resumed so the agent continues where it left off.
run_claude_step() {
    local prompt_file="$1"
    local log_file="$2"
    local expected_output="$3"
    local model="$4"
    local session_file="${log_file%.log}.session"
    local session_id
    local transient_attempt=1
    local invocation=0
    local resume=0
    local status=1
    local limit_waited=0
    local max_limit_wait=$((MAX_LIMIT_WAIT_HOURS * 3600))
    local attempt_log wait resume_at

    session_id="$(new_session_id)"
    echo "${session_id}" > "${session_file}"
    echo "    session: ${session_id}"
    : > "${log_file}"

    while true; do
        wait_for_shared_limit

        invocation=$((invocation + 1))
        attempt_log="${log_file%.log}.attempt-${invocation}.log"

        set +e
        if [[ "${resume}" -eq 0 ]]; then
            claude -p "$(cat "${prompt_file}")" \
                --session-id "${session_id}" \
                --model "${model}" \
                --setting-sources project \
                --permission-mode "${PERMISSION_MODE}" \
                < /dev/null 2>&1 | tee "${attempt_log}"
        else
            echo "    resuming session ${session_id}..."
            claude -p "${CLAUDE_CONTINUE_PROMPT}" \
                --resume "${session_id}" \
                --model "${model}" \
                --setting-sources project \
                --permission-mode "${PERMISSION_MODE}" \
                < /dev/null 2>&1 | tee "${attempt_log}"
        fi
        status="${PIPESTATUS[0]}"
        set -e
        cat "${attempt_log}" >> "${log_file}"

        if is_usage_limit_failure "${attempt_log}"; then
            wait="$(usage_limit_wait_seconds "${attempt_log}")"
            if [[ "${max_limit_wait}" -gt 0 && $((limit_waited + wait)) -gt "${max_limit_wait}" ]]; then
                echo "    usage limit wait would exceed --max-limit-wait ${MAX_LIMIT_WAIT_HOURS}h; giving up"
                return 1
            fi
            resume_at=$(( $(date +%s) + wait ))
            publish_shared_limit "${resume_at}"
            echo "    usage limit hit; sleeping $((wait / 60))m until $(date -r "${resume_at}" +"%a %H:%M"), then resuming..."
            sleep "${wait}"
            limit_waited=$((limit_waited + wait))
            resume=1
            continue
        fi

        if [[ "${status}" -eq 0 ]]; then
            return 0
        fi

        if [[ "${resume}" -eq 1 ]] && is_missing_session_failure "${attempt_log}"; then
            echo "    session ${session_id} could not be resumed; starting a fresh session"
            session_id="$(new_session_id)"
            echo "${session_id}" > "${session_file}"
            resume=0
            continue
        fi

        if [[ -f "${expected_output}" ]]; then
            # File written before a stream drop still counts as success.
            return 0
        fi

        if ! is_transient_claude_failure "${attempt_log}"; then
            return "${status}"
        fi

        transient_attempt=$((transient_attempt + 1))
        if [[ "${transient_attempt}" -gt "${CLAUDE_MAX_ATTEMPTS}" ]]; then
            return "${status}"
        fi
        echo "    retry ${transient_attempt}/${CLAUDE_MAX_ATTEMPTS} after transient API failure (resuming session)..."
        sleep $((transient_attempt * 3))
        resume=1
    done
}

run_step() {
    local step="$1"
    local company="$2"
    local log_dir="$3"
    local prompt_file="${log_dir}/step-${step}-prompt.txt"
    local log_file="${log_dir}/step-${step}.log"
    local model
    local expected_output
    local prompt_text

    if [[ "${DRY_RUN}" -eq 0 || "${step}" -eq "${FROM_STEP}" ]]; then
        validate_prerequisites "${company}" "${step}"
    fi
    prompt_text="$(step_prompt "${step}" "${company}")"
    expected_output="$(expected_output_for_step "${step}" "${company}")"
    model="$(model_for_step "${step}")"

    echo "==> Step ${step}/4 (model: ${model})"

    if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "    expected output: ${expected_output#${PROJECT_ROOT}/}"
        echo "    [dry-run] claude -p \"...\" --session-id <uuid> --model ${model} --setting-sources project --permission-mode ${PERMISSION_MODE}"
        printf '%s\n' "${prompt_text}" | sed 's/^/    | /' | head -n 40
        if [[ "$(printf '%s\n' "${prompt_text}" | wc -l | tr -d ' ')" -gt 40 ]]; then
            echo "    | ... (prompt truncated in dry-run display)"
        fi
        return 0
    fi

    step_prompt "${step}" "${company}" > "${prompt_file}"
    echo "    prompt: ${prompt_file#${PROJECT_ROOT}/}"
    echo "    log:    ${log_file#${PROJECT_ROOT}/}"

    if ! run_claude_step "${prompt_file}" "${log_file}" "${expected_output}" "${model}"; then
        die "step ${step} failed — see ${log_file#${PROJECT_ROOT}/}"
    fi

    if [[ ! -f "${expected_output}" ]]; then
        die "step ${step} finished but expected output is missing: ${expected_output#${PROJECT_ROOT}/}"
    fi

    echo "    wrote: ${expected_output#${PROJECT_ROOT}/}"
}

run_to_pdf() {
    local company="$1"
    local to_pdf="${SCRIPT_DIR}/to-pdf.sh"

    [[ -x "${to_pdf}" ]] || die "to-pdf script not found or not executable: ${to_pdf}"

    echo "==> PDF export"
    if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "    [dry-run] ${to_pdf} ${company}"
        return 0
    fi

    "${to_pdf}" "${company}"
}

main() {
    parse_args "$@"

    command -v claude >/dev/null 2>&1 || die "claude CLI not found in PATH"
    ensure_claude_skills

    local app_dir="${PROJECT_ROOT}/applications/${COMPANY}"
    local timestamp log_dir
    timestamp="$(date +"%Y%m%d-%H%M%S")"
    log_dir="${app_dir}/pipeline-logs/${timestamp}"

    echo "Pipeline: applications/${COMPANY}"
    if [[ "${MODEL_SET}" -eq 1 ]]; then
        echo "Model:    ${MODEL}"
    else
        echo "Models:   steps 1–3: ${DEFAULT_CLAUDE_MODEL}; step 4: ${DEFAULT_CLAUDE_STEP4_MODEL}"
    fi
    if [[ "${DRY_RUN}" -eq 0 ]]; then
        mkdir -p "${log_dir}"
        echo "Logs:     ${log_dir#${PROJECT_ROOT}/}"
    else
        echo "Mode:     dry-run (no agent invocations, no log files written)"
    fi
    echo

    local step ran_step_4=0
    for step in 1 2 3 4; do
        [[ "${step}" -ge "${FROM_STEP}" ]] || continue
        run_step "${step}" "${COMPANY}" "${log_dir}"
        [[ "${step}" -eq 4 ]] && ran_step_4=1
        echo
    done

    if [[ "${ran_step_4}" -eq 1 && "${SKIP_PDF}" -eq 0 ]]; then
        run_to_pdf "${COMPANY}"
        echo
    fi

    echo "Pipeline complete for applications/${COMPANY}"
    if [[ "${DRY_RUN}" -eq 0 ]]; then
        echo "Logs saved under ${log_dir#${PROJECT_ROOT}/}"
    fi
}

main "$@"
