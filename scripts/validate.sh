#!/usr/bin/env bash
# Pentagent repository validation.
# Verifies the OpenCode adapter config, the setup manifest, and the prompt/skill
# graph stay internally consistent. No network access, no installs.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAIL=0
pass() { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; FAIL=1; }

echo "[1/6] Required files present"
for f in \
  README.md LICENSE CONTRIBUTING.md AGENTS.md .gitignore opencode.jsonc \
  prompts/pentagent-system.md prompts/agents/setup-manifest.yaml \
  docs/ARCHITECTURE.md docs/INTEGRATION.md docs/SETUP.md docs/ROADMAP.md
do
  if [ -f "$f" ]; then pass "$f"; else fail "missing $f"; fi
done

# Strip // line comments (respecting strings) and write the JSON body to $STRIPPED.
STRIPPED="${TMPDIR:-/tmp}/pentagent-oc.json"
strip_jsonc() {
  python3 - "$ROOT" "$STRIPPED" <<'PY'
import pathlib, sys
root, dst = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
raw = (root / "opencode.jsonc").read_text()
out, in_str, esc, in_comment = [], False, False, False
for ch in raw:
    if in_comment:
        if ch == "\n":
            out.append(ch); in_comment = False
        continue
    if in_str:
        out.append(ch)
        if esc: esc = False
        elif ch == "\\": esc = True
        elif ch == '"': in_str = False
    else:
        if ch == '"': in_str = True; out.append(ch)
        elif ch == "/" and out and out[-1] == "/":
            while out and out[-1] != "\n": out.pop()
            in_comment = True
        else: out.append(ch)
dst.write_text("".join(out))
PY
}
strip_jsonc

echo "[2/6] opencode.jsonc parses and agent file references resolve"
python3 - "$ROOT" "$STRIPPED" <<'PY'
import json, pathlib, re, sys
root, sp = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
try:
    cfg = json.loads(sp.read_text())
except json.JSONDecodeError as e:
    print(f"  FAIL invalid JSONC: {e}"); sys.exit(1)
agents = cfg.get("agent", {})
missing = []
if not agents: missing.append("no agents defined")
for name, ag in agents.items():
    sys_ = (ag or {}).get("system", "")
    for m in re.finditer(r"\{file:\./?([^}]+)\}", sys_):
        if not (root / m.group(1)).is_file(): missing.append(f"{name}: {m.group(1)}")
if missing:
    print("  FAIL", *[f"    {m}" for m in missing], sep="\n")
    sys.exit(1)
print(f"  OK   {len(agents)} agents, all system file refs resolve")
sys.exit(0)
PY
[ "$?" -eq 0 ] || FAIL=1

echo "[3/6] Every /command maps to a known agent"
python3 - "$ROOT" "$STRIPPED" <<'PY'
import json, pathlib, re, sys
root, sp = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
cfg = json.loads(sp.read_text())
agents = set(cfg.get("agent", {}).keys())
cmds = sorted((root / ".opencode/commands").glob("*.md"))
bad = []
for cmd in cmds:
    t = cmd.read_text()
    fm = re.match(r"^---\n(.*?)\n---", t, re.S)
    if not fm:
        bad.append(f"{cmd.name}: missing frontmatter"); continue
    meta = dict(re.findall(r"^(\w+):\s*(.+)$", fm.group(1), re.M))
    if not meta.get("description"): bad.append(f"{cmd.name}: no description")
    if meta.get("agent") not in agents: bad.append(f"{cmd.name}: agent '{meta.get('agent')}' unknown")
if bad:
    print("  FAIL", *[f"    {b}" for b in bad], sep="\n")
    sys.exit(1)
print(f"  OK   all {len(cmds)} commands reference known agents")
sys.exit(0)
PY
[ "$?" -eq 0 ] || FAIL=1
rm -f "$STRIPPED"

echo "[4/6] Skill frontmatter matches directory names"
OK=1
for sk in .opencode/skills/*/SKILL.md; do
  [ -f "$sk" ] || continue
  dirname="$(basename "$(dirname "$sk")")"
  name="$(sed -n 's/^name:[[:space:]]*//p' "$sk" | head -1 | tr -d '[:space:]')"
  if [ "$name" = "$dirname" ]; then pass "$sk ($name)"; else fail "$sk name='$name' != dir '$dirname'"; OK=0; fi
done
[ "$OK" -eq 1 ] || FAIL=1

echo "[5/6] Setup manifest structure"
python3 - "$ROOT" <<'PY'
import pathlib, sys
try:
    import yaml
except ImportError:
    print("  WARN  pyyaml not available; skipping deep manifest checks")
    sys.exit(0)
root = pathlib.Path(sys.argv[1])
d = yaml.safe_load((root / "prompts/agents/setup-manifest.yaml").read_text())
errs = []
if not isinstance(d.get("host_req"), list): errs.append("host_req missing")
for hr in d.get("host_req", []):
    for k in ("name", "check", "un_solvable"):
        if not hr.get(k): errs.append(f"host_req missing {k}: {hr.get('name')}")
cats = set(d.get("categories", {}))
for name, prof in d.get("profiles", {}).items():
    for s in prof.get("stages", []):
        if s not in cats: errs.append(f"profile '{name}' stage '{s}' not in categories")
for i, t in enumerate(d.get("tools", [])):
    if not t.get("name"): errs.append(f"tool #{i} missing name")
    if not t.get("verify"): errs.append(f"tool '{t.get('name')}' missing verify")
    if t.get("category") not in cats: errs.append(f"tool '{t.get('name')}' bad category")
    if not isinstance(t.get("size_mb"), (int, float)): errs.append(f"tool '{t.get('name')}' bad size_mb")
    if not t.get("pm") and not t.get("sources"): errs.append(f"tool '{t.get('name')}' has no install source")
if errs:
    print("  FAIL", *[f"    {e}" for e in errs], sep="\n")
    sys.exit(1)
print(f"  OK   manifest: {len(d.get('tools', []))} tools, {len(d.get('profiles', {}))} profiles, {len(d.get('host_req', []))} host_req")
sys.exit(0)
PY
[ "$?" -eq 0 ] || FAIL=1

echo "[6/6] README /command references resolve"
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
readme = (root / "README.md").read_text()
cmds = {p.stem for p in (root / ".opencode/commands").glob("*.md")}
refs = sorted(set(re.findall(r"`/([a-z][a-z0-9-]*)", readme)))
bad = [r for r in refs if r not in cmds]
if bad:
    print("  FAIL unknown /command refs:", *bad, sep="\n    ")
    sys.exit(1)
print(f"  OK   README references commands: {', '.join(refs) or '(none)'}")
sys.exit(0)
PY
[ "$?" -eq 0 ] || FAIL=1

echo
if [ "$FAIL" -eq 0 ]; then
  printf '\033[32mAll checks passed.\033[0m\n'
  exit 0
else
  printf '\033[31mValidation failed.\033[0m\n'
  exit 1
fi