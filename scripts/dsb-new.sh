#!/usr/bin/env bash
# dsb-new.sh - scaffold a new Dasharo Security Bulletin from the template
#
# Usage:
#   ./scripts/dsb-new.sh --title "Short title of the issue"
#   ./scripts/dsb-new.sh --title "..." --number 003 --date 2026-05-01
#
# Arguments:
#   --title   (required) one-line title of the bulletin
#   --number  (optional) zero-padded DSB number; auto-increments if omitted
#   --date    (optional) publication date YYYY-MM-DD; defaults to today

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DSBS_DIR="${REPO_ROOT}/DSBs"
TEMPLATE="${DSBS_DIR}/3mdeb-dsb-template.txt"

usage() {
    echo "Usage: $0 --title <title> [--number <NNN>] [--date <YYYY-MM-DD>]"
    exit 1
}

# Parse arguments
TITLE=""
NUMBER=""
DATE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --title)
            TITLE="$2"
            shift 2
            ;;
        --number)
            NUMBER="$2"
            shift 2
            ;;
        --date)
            DATE="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage
            ;;
    esac
done

if [[ -z "${TITLE}" ]]; then
    echo "Error: --title is required." >&2
    usage
fi

# Default date to today
if [[ -z "${DATE}" ]]; then
    DATE="$(date +%Y-%m-%d)"
fi

# Validate date format
if ! [[ "${DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: --date must be in YYYY-MM-DD format." >&2
    exit 1
fi

# Auto-increment number if not provided
if [[ -z "${NUMBER}" ]]; then
    # Find highest existing DSB number in DSBs/
    HIGHEST=0
    for f in "${DSBS_DIR}"/dsb-[0-9]*.txt; do
        [[ -e "$f" ]] || continue
        BASENAME="$(basename "$f")"
        # Extract number: dsb-NNN-... or dsb-NNN.txt
        NUM="$(echo "${BASENAME}" | sed -n 's/^dsb-\([0-9]*\).*/\1/p')"
        if [[ -n "${NUM}" ]]; then
            NUM_DEC=$((10#${NUM}))
            if [[ ${NUM_DEC} -gt ${HIGHEST} ]]; then
                HIGHEST=${NUM_DEC}
            fi
        fi
    done
    NEXT=$((HIGHEST + 1))
    NUMBER="$(printf '%03d' "${NEXT}")"
fi

# Zero-pad number if provided without padding
NUMBER="$(printf '%03d' "$((10#${NUMBER}))")"

OUTPUT="${DSBS_DIR}/dsb-${NUMBER}-${DATE}.txt"

if [[ -e "${OUTPUT}" ]]; then
    echo "Error: ${OUTPUT} already exists." >&2
    exit 1
fi

if [[ ! -f "${TEMPLATE}" ]]; then
    echo "Error: template not found at ${TEMPLATE}" >&2
    exit 1
fi

# Substitute placeholders in the template
sed \
    -e "s/NNN/${NUMBER}/g" \
    -e "s/Short title of the issue (one line)/${TITLE}/" \
    -e "s/YYYY-MM-DD/${DATE}/g" \
    "${TEMPLATE}" > "${OUTPUT}"

echo "Created: ${OUTPUT}"
echo ""
echo "Next steps:"
echo "  1. Fill in all sections of ${OUTPUT}"
echo "  2. Get internal review (EFT TL/EM for technical accuracy, PM for tone)"
echo "  3. Sign with: ./scripts/sign.sh ${OUTPUT}"
echo "  4. Merge DSBs/dsb-${NUMBER}-${DATE}.txt and .sig files to main"
