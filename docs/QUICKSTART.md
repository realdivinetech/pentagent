# Pentagent quick start

A first-session walkthrough. Both paths below use the same portable core —
only the loading mechanism differs.

## 0. Prerequisites

- A Linux host you own (Kali recommended; Debian/Ubuntu family fine).
- An AI agent CLI: OpenCode (turnkey) or Claude Code / Gemini CLI / similar.
- Network access for tool installs and OSINT.
- Approved targets only (your own systems, labs, CTFs, or a signed-off
  engagement).

## 1. Get the code

```bash
git clone https://github.com/realdivinetech/pentagent.git
cd pentagent
```

## 2. OpenCode path (turnkey)

The OpenCode wiring (`.opencode/`, `opencode.jsonc`) is local and git-ignored;
restore or build it per `docs/INTEGRATION.md`, then:

```bash
opencode        # in the pentagent/ folder
```

Inside the session you get slash commands:

| Command | When to use |
|---------|-------------|
| `/setup webapp` | First run — provision tools you're missing (audits first) |
| `/engage <slug>` | Start a target workspace (scope, objectives, folders) |
| `/osint <target>` | Passive footprint of an authorized target |
| `/plan` | Task tree + MITRE ATT&CK kill-chain map |
| `/critique` | Validate findings before they enter the report |
| `/report` | Generate the final report + detections + remediation |

## 3. Other-agent path (generic)

```bash
export SYSTEM="$(cat prompts/pentagent-system.md)"
# your CLI loads $SYSTEM as its system/developer instruction, cwd = pentagent/
```
Map the specialists in `prompts/agents/` to your tool's subagents/skills.
See `docs/INTEGRATION.md` for Claude Code / Gemini CLI / Cursor / custom LLM
snapshots.

## 4. Your first engagement

1. **Scope it.** `/engage my-lab` — enter the authorized target, boundaries,
   and rules of engagement. → creates `engagements/my-lab/`.
2. **Recon.** `/osint <target>` then enumerate (nmap, whatweb, header review).
3. **Test hypothesis-driven.** Ask the agent to validate the highest-value
   finding first; require proof (request/response or command output).
4. **Validate.** `/critique` — dedupes, calibrates severity, flags anything
   not backed by evidence.
5. **Report.** `/report` — executive + technical sections, detection
   guidance, remediation, evidence appendix.

A working example of this exact flow is documented in
`engagements/README.md` (local) and was exercised against Juice Shop + DVWA
in a lab.

## 5. Practice + safety

- Rehearse on OWASP Juice Shop / DVWA / Metasploitable (local Docker) before
  anything real. Links: `prompts/skills` web-pentest skill.
- Pentagent never installs without approval; the setup agent prefers
  user-space installs and supervised sudo (see `docs/SETUP.md`).
- Engagement data lives in gitignored `engagements/` — nothing real is
  pushed to the public repo.
- Stop on scope creep: a discovered adjacent asset never expands the
  authorized boundary.