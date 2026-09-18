# Pentagent

> A modular, provider-agnostic AI agent for **authorized** penetration testing and offensive-security research.

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Pentagent** is a personal security-operations agent that plans, executes, analyzes, validates, documents, and remediates security assessments on authorized targets. It ships as **portable prompt + skills** (runtime-agnostic Markdown) with a thin adapter for **OpenCode on Kali Linux** as the first runtime.

Author: [realdivinetech](https://github.com/realdivinetech)

## Philosophy

Pentagent behaves like a senior security operator:

> **Understand → Scope → Recon → Enumerate → Hypothesize → Test → Validate → Assess Impact → Evidence → Remediate → Retest**

It never blindly runs every scanner. Every next action is chosen from what the previous evidence shows, scanner indications stay distinct from confirmed findings, and neurotic noise never replaces signal.

## What it does

- **Specialist agent team** — each a portable canonical prompt in `prompts/agents/`:

  | Agent | Role |
  |-------|------|
  | `pentagent` | Primary operator: orchestrates the engagement end to end |
  | `osint` | Passive open-source intelligence: footprint, identities, tech, relationships |
  | `evidence` | Engagement keeper: persists all target info into a per-target workspace |
  | `planner` | Engagement strategist: persistent task tree + MITRE ATT&CK kill-chain map |
  | `critic` | Validation gate: 6-stage finding ladder, dedupe, severity calibration |
  | `report-writer` | Professional, defensible reports (executive + technical, PoC + detection rules) |
  | `setup` | Provisioner: bootstraps a fresh Linux host into a ready security workstation |

- **Engagement workspace** — every target gets an isolated folder (`$PENTAGENT_ENGAGEMENTS_DIR` or `engagements/<slug>`) with `scope.md`, `deconfliction.md`, `tasks.md`, and separated `recon/ osint/ evidence/ findings/ notes/ reports/`. Nothing is lost across sessions or context trims.

- **Setup / provisioning system** — one command turns a freshly launched Linux box into a fully equipped workstation: staged installs from a data manifest, ordered fallback sources, self-healing error loop, disk-space planning, and explicit hand-off of blockers it cannot solve. See `docs/SETUP.md`.

- **Research-driven** — Pentagent verifies CVEs, tool syntax, and exploit details against NVD, Exploit-DB, Packet Storm, GitHub advisories, HackTricks, and vendor sources before acting, and records every reference with the evidence it supports.

## Repository layout

```text
Pentagent/
├── README.md
├── AGENTS.md                  # project rules + agent roster
├── opencode.jsonc             # first runtime adapter (OpenCode)
├── prompts/
│   ├── pentagent-system.md    # primary operator prompt
│   └── agents/                # portable specialist prompts
│       ├── osint.md  evidence.md  planner.md
│       ├── critic.md  report-writer.md  setup.md
│       └── setup-manifest.yaml       # setup tool inventory (data)
├── .opencode/
│   ├── agents/  commands/  skills/
│   └── skills/                # skill workflows (audit, pentest, reporting…)
├── docs/
│   ├── ARCHITECTURE.md  INTEGRATION.md  SETUP.md  ROADMAP.md
└── engagements/               # per-target workspaces (gitignored)
```

## Quick start (OpenCode)

```bash
cd Pentagent
opencode
```

Then use the built-in commands inside the agent:

| Command | Purpose |
|---------|---------|
| `/setup [profile]` | Provision this host (profiles: `standard`, `webapp`, `netad`, `minimal`) |
| `/tool-audit` | Report installed vs. missing tools against the setup manifest |
| `/engage` | Start a new engagement workspace for a target |
| `/osint` | Run passive OSINT on an authorized target |
| `/plan` | Build/update the task tree + ATT&CK kill-chain map |
| `/critique` | Run the critic validation gate over findings |
| `/report` | Generate the professional report |
| `/research` | Live threat/vulnerability research |

## Operational scripts & templates

| Item | Purpose |
|------|---------|
| `scripts/validate.sh` | Repo consistency check (CI runs it on every push/PR) |
| `scripts/audit.sh [profile]` | Host tool audit vs. the setup manifest (`standard` default; profiles: `webapp`, `netad`, `minimal`) |
| `templates/engagement/` | Blank, copy-able engagement workspace (scope, tasks, attack-chains, findings, critique, report skeleton) |

## Installation policy

Pentagent **never installs software without explicit user approval** — enforced both by prompt rule and by the OpenCode adapter's command-level permissions.

One deliberate exception: the `setup` provisioner agent is authorized to install and self-heal unattended (it is the tool that makes fresh hosts ready). Its elevated grants exist only inside that agent's own wiring, never in the global permission map, and destructive host operations remain blocked even for it.

## Safety model

- Scope is a hard boundary; discovered adjacent assets never expand it.
- Confirmed ≠ scanner hit. Every finding passes the critic's validation ladder before reporting.
- Destructive/system-sensitive operations (`rm -rf /`, `mkfs`, repartitioning, power-off) are denied by the adapter, including inside the elevated `setup` agent.
- Client data, credentials, and real engagement evidence are held in gitignored local directories.

## Portability

The canonical prompts and skills live outside any runtime-specific configuration. OpenCode is the first adapter; the same prompts map to other agent runtimes without changing core behavior. See `docs/INTEGRATION.md` for the adapter pattern.

## License

Released under the [MIT License](LICENSE).

Copyright (c) 2026 Ojo Divine-favour Damilare (realdivinetech).

Anyone may use, copy, modify, merge, publish, distribute, sublicense, and sell the software, provided the copyright and permission notices are preserved. See the [LICENSE](LICENSE) file for the full terms.

Contributions are accepted under the same license — see [CONTRIBUTING](CONTRIBUTING.md).

## GitHub

This repository is public. Engagement data under `engagements/` and setup logs under `setup/` are gitignored and never pushed. Do not commit real client evidence, credentials, or tokens to this repository.