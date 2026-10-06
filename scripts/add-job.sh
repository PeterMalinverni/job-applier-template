#!/usr/bin/env bash
# Create applications/<company>/job-description.md so the pipeline can run.
#
# Usage:
#   ./scripts/add-job.sh <company-kebab> [jd-file]
#
# The job description comes from, in order of preference:
#   1. jd-file, if given
#   2. stdin, if it is piped or redirected
#   3. the clipboard (pbpaste on macOS; wl-paste or xclip on Linux)
#
# Examples:
#   ./scripts/add-job.sh acme-corp ~/Downloads/acme-jd.txt
#   ./scripts/add-job.sh acme-corp < acme-jd.md
#   ./scripts/add-job.sh acme-corp            # copy the JD first, then run
#
# Then: ./scripts/run-pipeline.sh acme-corp
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
    awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$0"
}

die() {
    echo "error: $*" >&2
    exit 1
}

read_clipboard() {
    if command -v pbpaste >/dev/null 2>&1; then
        pbpaste
    elif command -v wl-paste >/dev/null 2>&1; then
        wl-paste
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard -o
    else
        die "no clipboard tool found; pass a file or pipe the JD on stdin"
    fi
}

[[ $# -ge 1 && "$1" != "-h" && "$1" != "--help" ]] || { usage; exit 0; }

COMPANY="$1"
[[ "${COMPANY}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] \
    || die "company must be kebab-case (e.g. acme-corp), got: ${COMPANY}"

APP_DIR="${PROJECT_ROOT}/applications/${COMPANY}"
JD_FILE="${APP_DIR}/job-description.md"
[[ ! -e "${JD_FILE}" ]] || die "already exists: applications/${COMPANY}/job-description.md"

if [[ $# -ge 2 ]]; then
    [[ -f "$2" ]] || die "file not found: $2"
    JD="$(cat "$2")"
elif [[ ! -t 0 ]]; then
    JD="$(cat)"
else
    JD="$(read_clipboard)"
fi

[[ -n "${JD//[[:space:]]/}" ]] || die "job description is empty"

mkdir -p "${APP_DIR}"
printf '%s\n' "${JD}" > "${JD_FILE}"
echo "wrote applications/${COMPANY}/job-description.md ($(wc -w < "${JD_FILE}" | tr -d ' ') words)"
echo "next: ./scripts/run-pipeline.sh ${COMPANY}"
