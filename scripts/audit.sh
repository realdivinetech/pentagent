#!/usr/bin/env bash
# Pentagent host audit — tool-availability linter.
# Reads the single source of truth (prompts/agents/setup-manifest.yaml) and
# reports which host prerequisites / profile tools are installed, which are
# missing, and how much disk the missing install needs.
#
#   bash scripts/audit.sh [profile]     # profile default: standard
#
# Exit code: 0 = ready (all host_req pass and no required tool missing),
#            1 = gaps found (or pyyaml unavailable for deep checks);
#            2 = unknown profile.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PROFILE="${1:-standard}"

PASS=0
MISS=0

python3 - "$ROOT" "$PROFILE" <<'PY'
import pathlib, subprocess, sys
root, profile = pathlib.Path(sys.argv[1]), sys.argv[2]
try:
    import yaml
except ImportError:
    print("WARN  pyyaml not available; cannot audit manifest")
    sys.exit(3)
d = yaml.safe_load((root / "prompts/agents/setup-manifest.yaml").read_text())

prof = d.get("profiles", {}).get(profile)
if not prof:
    print(f"unknown profile '{profile}' (have: {', '.join(d.get('profiles', {}))})")
    sys.exit(2)

stages = set(prof["stages"])
cats = d["categories"]
tools = [t for t in d["tools"] if t["category"] in stages]

def check(cmd):
    try:
        return subprocess.run(["bash", "-c", cmd], capture_output=True, timeout=6).returncode == 0
    except subprocess.TimeoutExpired:
        return False

print(f"== {profile} profile: stages = {sorted(stages)} ({len(tools)} tools) ==")
print("\n-- host_req --")
host_ok = True
for r in d["host_req"]:
    ok = check(r["check"])
    host_ok &= ok
    print(("OK  " if ok else "MISS"), r["name"])
    if not ok:
        print("     -> %s" % r.get("un_solvable", "see manifest"))

print("\n-- tools --")
present, missing = [], []
for t in tools:
    ok = check(t.get("verify", t.get("cmd", "")))
    (present if ok else missing).append(t["name"])
    print(("OK  " if ok else "MISS"), t["name"])

size = sum(t.get("size_mb", 0) for t in d["tools"] if t["name"] in missing and t["category"] in stages)
print(f"\npresent {len(present)} / missing {len(missing)}")
if missing:
    print("missing:", ", ".join(missing))
    print(f"needed install size: ~{size} MB (+30%% headroom -> ~{int(size*1.3)} MB)")
req_missing = [t["name"] for t in d["tools"] if t["name"] in missing and t.get("required") and t["category"] in stages]
if host_ok and not req_missing:
    print("AUDIT READY (required tools present)")
    sys.exit(0)
print("AUDIT GAPS DETECTED")
sys.exit(1)
PY
rc=$?

if [ "$rc" -eq 3 ] || [ "$rc" -eq 2 ]; then exit "$rc"; fi
exit "$rc"