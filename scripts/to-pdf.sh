#!/usr/bin/env bash
# Convert a tailored resume HTML file to PDF in-place, using headless Chrome.
#
# Usage:
#     ./scripts/to-pdf.sh <application-dir-name>
#     ./scripts/to-pdf.sh --full-path <path-to-html-file>
#
# Examples:
#     ./scripts/to-pdf.sh base-power
#     ./scripts/to-pdf.sh --full-path ~/Documents/resume.html
#
# Requires: Google Chrome, Chromium, Brave, or Microsoft Edge (macOS app or a
# google-chrome / chromium binary on PATH). No Python / pip / Homebrew dependencies.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
    echo "usage: $(basename "$0") <application-dir-name>" >&2
    echo "       $(basename "$0") --full-path <path-to-html-file>" >&2
}

FULL_PATH_MODE=0
HTML_PATH=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --full-path)
            FULL_PATH_MODE=1
            shift
            if [[ $# -lt 1 ]]; then
                echo "error: --full-path requires a file path" >&2
                usage
                exit 2
            fi
            expanded="${1/#\~/$HOME}"
            HTML_PATH="$(cd "$(dirname "${expanded}")" && pwd)/$(basename "${expanded}")"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [[ $FULL_PATH_MODE -eq 1 ]]; then
                echo "error: unexpected argument: $1" >&2
                usage
                exit 2
            fi
            if [[ -n "${APP_NAME:-}" ]]; then
                echo "error: unexpected argument: $1" >&2
                usage
                exit 2
            fi
            APP_NAME="$1"
            shift
            ;;
    esac
done

if [[ $FULL_PATH_MODE -eq 1 ]]; then
    if [[ ! -f "${HTML_PATH}" ]]; then
        echo "error: HTML file not found: ${HTML_PATH}" >&2
        exit 1
    fi
    html_ext="${HTML_PATH##*.}"
    html_ext="$(printf '%s' "${html_ext}" | tr '[:upper:]' '[:lower:]')"
    case "${html_ext}" in
        html|htm) ;;
        *)
            echo "error: expected an HTML file (.html or .htm): ${HTML_PATH}" >&2
            exit 1
            ;;
    esac
elif [[ -z "${APP_NAME:-}" ]]; then
    usage
    exit 2
else
    APP_DIR="${PROJECT_ROOT}/applications/${APP_NAME}"

    if [[ ! -d "${APP_DIR}" ]]; then
        echo "error: application directory not found: ${APP_DIR}" >&2
        exit 1
    fi
fi

# Find the resume HTML: prefer *Resume*.html; fall back to 04-resume.html;
# fall back to the sole *.html if that's unambiguous.
find_resume_html() {
    local matches=()
    while IFS= read -r -d '' f; do matches+=("$f"); done < <(
        find "${APP_DIR}" -maxdepth 1 -type f -iname "*resume*.html" -print0
    )
    if [[ ${#matches[@]} -eq 1 ]]; then echo "${matches[0]}"; return; fi
    if [[ ${#matches[@]} -gt 1 ]]; then
        if [[ -f "${APP_DIR}/04-resume.html" ]]; then
            echo "${APP_DIR}/04-resume.html"; return
        fi
        echo "error: multiple resume-looking HTML files found in ${APP_DIR}:" >&2
        printf '  - %s\n' "${matches[@]}" >&2
        exit 1
    fi
    local all=()
    while IFS= read -r -d '' f; do all+=("$f"); done < <(
        find "${APP_DIR}" -maxdepth 1 -type f -iname "*.html" -print0
    )
    if [[ ${#all[@]} -eq 1 ]]; then echo "${all[0]}"; return; fi
    echo "error: could not identify a unique resume HTML file in ${APP_DIR}" >&2
    exit 1
}

find_chrome() {
    local candidates=(
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        "/Applications/Chromium.app/Contents/MacOS/Chromium"
        "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
        "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    )
    for c in "${candidates[@]}"; do
        if [[ -x "$c" ]]; then echo "$c"; return; fi
    done
    for c in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge; do
        if command -v "$c" >/dev/null 2>&1; then command -v "$c"; return; fi
    done
    echo "error: no Chrome/Chromium/Brave/Edge binary found under /Applications or on PATH" >&2
    exit 1
}

if [[ $FULL_PATH_MODE -eq 0 ]]; then
    HTML_PATH="$(find_resume_html)"
fi

CHROME_BIN="$(find_chrome)"
PDF_PATH="${HTML_PATH%.*}.pdf"

# Chrome's --print-to-pdf writes to the CWD (or an absolute path). Use file://
# so linked stylesheets resolve relative to the HTML file.
"${CHROME_BIN}" \
    --headless=new \
    --disable-gpu \
    --no-pdf-header-footer \
    --print-to-pdf="${PDF_PATH}" \
    "file://${HTML_PATH}" \
    >/dev/null 2>&1

if [[ "${PDF_PATH}" == "${PROJECT_ROOT}/"* ]]; then
    echo "Wrote ${PDF_PATH#${PROJECT_ROOT}/}"
else
    echo "Wrote ${PDF_PATH}"
fi
