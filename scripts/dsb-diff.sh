#!/usr/bin/env bash
# dsb-diff.sh - summarize component version changes between two Dasharo releases
#
# Compares framework and component versions from project_config.yaml and lists
# fixed issues from releases.yaml. Useful when writing the Details or Patching
# sections of a DSB.
#
# Usage (board directory + version tags):
#   ./scripts/dsb-diff.sh --board-dir <path> --from <version> --to <version>
#
#   --board-dir  path to the board payload directory that contains per-version
#                subdirectories, e.g. boards/msi/ms7d25/uefi
#   --from       version tag of the older release, e.g. v1.1.1
#   --to         version tag of the newer release, e.g. v1.1.2
#
# Usage (explicit config file paths):
#   ./scripts/dsb-diff.sh --from-config <path> --to-config <path>
#
#   --from-config  path to the older project_config.yaml
#   --to-config    path to the newer project_config.yaml
#
# Examples:
#   ./scripts/dsb-diff.sh \
#       --board-dir path/to/dasharo/boards/msi/ms7d25/uefi \
#       --from v1.1.1 --to v1.1.2
#
#   ./scripts/dsb-diff.sh \
#       --from-config boards/msi/ms7d25/uefi/v1.1.1/project_config.yaml \
#       --to-config   boards/msi/ms7d25/uefi/v1.1.2/project_config.yaml

set -euo pipefail

BOARD_DIR=""
FROM_VER=""
TO_VER=""
FROM_CONFIG=""
TO_CONFIG=""

usage() {
    echo "Usage:"
    echo "  $0 --board-dir <path> --from <version> --to <version>"
    echo "  $0 --from-config <path> --to-config <path>"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --board-dir)  BOARD_DIR="$2";   shift 2 ;;
        --from)       FROM_VER="$2";    shift 2 ;;
        --to)         TO_VER="$2";      shift 2 ;;
        --from-config) FROM_CONFIG="$2"; shift 2 ;;
        --to-config)   TO_CONFIG="$2";   shift 2 ;;
        *) echo "Unknown argument: $1" >&2; usage ;;
    esac
done

# Resolve config paths
if [[ -n "${FROM_CONFIG}" && -n "${TO_CONFIG}" ]]; then
    : # explicit paths provided
elif [[ -n "${BOARD_DIR}" && -n "${FROM_VER}" && -n "${TO_VER}" ]]; then
    FROM_CONFIG="${BOARD_DIR}/${FROM_VER}/project_config.yaml"
    TO_CONFIG="${BOARD_DIR}/${TO_VER}/project_config.yaml"
else
    echo "Error: supply either --board-dir + --from + --to, or --from-config + --to-config" >&2
    usage
fi

for f in "${FROM_CONFIG}" "${TO_CONFIG}"; do
    if [[ ! -f "$f" ]]; then
        echo "Error: file not found: $f" >&2
        exit 1
    fi
done

# Derive releases.yaml paths (sibling of project_config.yaml)
FROM_RELEASES="$(dirname "${FROM_CONFIG}")/releases.yaml"
TO_RELEASES="$(dirname "${TO_CONFIG}")/releases.yaml"

python3 - "${FROM_CONFIG}" "${TO_CONFIG}" "${FROM_RELEASES}" "${TO_RELEASES}" <<'PYEOF'
import sys
import os

try:
    import yaml
except ImportError:
    sys.exit("Error: PyYAML is required. Install with: pip install pyyaml")

from_config_path, to_config_path, from_releases_path, to_releases_path = sys.argv[1:5]


def load_yaml(path):
    with open(path) as f:
        return yaml.safe_load(f)


def component_versions(cfg):
    """Return dict of component name -> version from a project_config.yaml."""
    versions = {}
    fw = cfg.get("framework", {})
    if fw:
        name = fw.get("name", "framework")
        versions[name] = fw.get("version", "(unknown)")
    for comp in cfg.get("components", []):
        name = comp.get("name", "(unnamed)")
        ver = comp.get("version", "(unknown)")
        rev = comp.get("revision")
        versions[name] = f"{ver} (rev: {rev})" if rev else str(ver)
    return versions


cfg_from = load_yaml(from_config_path)
cfg_to   = load_yaml(to_config_path)

from_label = cfg_from.get("framework", {}).get("version") or os.path.basename(os.path.dirname(from_config_path))
to_label   = cfg_to.get("framework", {}).get("version")   or os.path.basename(os.path.dirname(to_config_path))

vers_from = component_versions(cfg_from)
vers_to   = component_versions(cfg_to)

all_names = sorted(set(vers_from) | set(vers_to))

changed = []
added   = []
removed = []

for name in all_names:
    v_from = vers_from.get(name)
    v_to   = vers_to.get(name)
    if v_from is None:
        added.append((name, v_to))
    elif v_to is None:
        removed.append((name, v_from))
    elif v_from != v_to:
        changed.append((name, v_from, v_to))

platform_from = cfg_from.get("dasharo", {}).get("platform", "")
platform_to   = cfg_to.get("dasharo", {}).get("platform", "")
platform = platform_from or platform_to

print(f"Component diff: {platform or 'unknown platform'}")
print(f"  {os.path.basename(os.path.dirname(from_config_path))} -> "
      f"{os.path.basename(os.path.dirname(to_config_path))}")
print()

if changed:
    print("Changed:")
    for name, v_from, v_to in changed:
        print(f"  {name}")
        print(f"    {v_from} -> {v_to}")
else:
    print("Changed: (none)")

if added:
    print()
    print("Added:")
    for name, ver in added:
        print(f"  {name} {ver}")

if removed:
    print()
    print("Removed:")
    for name, ver in removed:
        print(f"  {name} {ver}")

# Fixed issues from releases.yaml in the TO version
if os.path.isfile(to_releases_path):
    releases_data = load_yaml(to_releases_path)
    to_ver_dir = os.path.basename(os.path.dirname(to_config_path))
    fixed_entries = []
    for release in (releases_data.get("releases") or []):
        if str(release.get("version", "")) == to_ver_dir:
            fixed_entries = release.get("fixed") or []
            break
    if fixed_entries:
        print()
        print(f"Fixed in {to_ver_dir} (from releases.yaml):")
        for entry in fixed_entries:
            desc = entry.get("description", "")
            url  = entry.get("url", "")
            line = f"  - {desc}"
            if url:
                line += f"\n    {url}"
            print(line)
    else:
        print()
        print(f"Fixed in {to_ver_dir}: (none listed in releases.yaml)")
else:
    print()
    print(f"(releases.yaml not found at {to_releases_path})")
PYEOF
