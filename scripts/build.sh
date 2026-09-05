#!/usr/bin/env bash
# Compile the IP Tracking PTE with the full analyzer set (runbook Step 06 action 5).
# Warnings are treated as errors (Operating Rule 5 / FRD §8): any warning fails the build.
#
#   ./scripts/build.sh            # pre-flight + compile everything under src/
#   ./scripts/build.sh src/Enums  # pre-flight that subtree, then compile the project
#
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out"

ALEXT=$(ls -d "$HOME"/.vscode/extensions/ms-dynamics-smb.al-* 2>/dev/null | sort -V | tail -1)
if [[ -z "$ALEXT" ]]; then
    echo "FAIL: AL Language extension not found under ~/.vscode/extensions" >&2
    exit 2
fi
case "$(uname -s)" in
    Darwin) PLAT=darwin ;;
    Linux)  PLAT=linux  ;;
    *)      PLAT=win32  ;;
esac
ALC="$ALEXT/bin/$PLAT/alc"
AN="$ALEXT/bin/Analyzers"
[[ -x "$ALC" ]] || chmod +x "$ALC" 2>/dev/null

echo "== pre-flight =="
python3 "$ROOT/scripts/preflight.py" "$@" || { echo "BUILD ABORTED: pre-flight failed."; exit 1; }

# Package filename = <AppName, spaces -> underscores>_<Version>.app — read from app.json,
# never hardcoded (Operating Rule 1). E.g. "IP Tracking" 1.0.0.0 -> IP_Tracking_1.0.0.0.app
APP_NAME=$(python3 -c "import json; print(json.load(open('$ROOT/app.json'))['name'].replace(' ', '_'))")
APP_VERSION=$(python3 -c "import json; print(json.load(open('$ROOT/app.json'))['version'])")
PACKAGE_FILE="${APP_NAME}_${APP_VERSION}.app"

echo
echo "== compile (CodeCop + UICop + PerTenantExtensionCop) =="
mkdir -p "$OUT"
LOG="$OUT/build.log"
"$ALC" /project:"$ROOT" /packagecachepath:"$ROOT/.alpackages" /out:"$OUT/$PACKAGE_FILE" \
    /analyzer:"$AN/Microsoft.Dynamics.Nav.CodeCop.dll" \
    /analyzer:"$AN/Microsoft.Dynamics.Nav.UICop.dll" \
    /analyzer:"$AN/Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll" 2>&1 | tee "$LOG"

ERRORS=$(grep -cE ': error [A-Z]+[0-9]+:' "$LOG" || true)
WARNINGS=$(grep -cE ': warning [A-Z]+[0-9]+:' "$LOG" || true)
INFOS=$(grep -cE ': info [A-Z]+[0-9]+:' "$LOG" || true)

echo
echo "== result: $ERRORS error(s), $WARNINGS warning(s), $INFOS info =="
if (( ERRORS > 0 || WARNINGS > 0 )); then
    echo "GATE FAILED — zero errors and zero warnings are required before the next batch."
    exit 1
fi
echo "GATE PASSED — $OUT/$PACKAGE_FILE"
