# Pentagent Roadmap — brainstormed functionality

Ideas for future capability. Each item should follow the project's layering rule:
portable prompt/skill in `prompts/` or `skills/`, thin runtime wiring in the adapter.

## Adopted from open-source agent survey

Surveyed best-of-breed security agents and adopted their strongest patterns:

| Pattern | Source agent(s) | Status in Pentagent |
|---------|-----------------|---------------------|
| Persistent task tree (PTT) that survives context trims | PentestGPT, PentestCode, LuaN1ao | `planner` agent + `tasks.md` |
| MITRE ATT&CK kill-chain map | Decepticon, WRAITH, HiveBreach | `planner` agent + `attack-chains.md` |
| Independent critic / false-positive gate | PentestCode, agent-smith adjudication, Fennec | `critic` agent (6-stage ladder) |
| RoE / ConOps / deconfliction engagement package | Decepticon | `deconfliction.md` + `objectives.md` on engage |
| Phase control with exit gates | PentestCode | phase status in `tasks.md` + `README.md` |
| Every finding must be PoC-reproducible; safe/inconclusive verdicts allowed | Fennec, agent-smith, HiveBreach | critic ladder + report PoC artifacts |
| Detection rules (Sigma/SPL/KQL) delivered with findings | pentest-ai (0xSteph), agent-smith | report-writer `Detection`/detections |
| Burp `.http`/script PoC artifacts | agent-smith | report-writer `PoC artifact` |

Surveyed but not yet adopted (open items, see below): MCP tool bridge
(GH05TCREW/PentestAgent, pentest-ai, Pentest-Swarm-AI), tmux interactive shells
(Decepticon, WRAITH), RAG/loot-optimizer (GH05TCREW), RL/cognitive reasoning
(WRAITH), causal-graph plan reasoning (LuaN1ao).

## Setup / provisioning system (adopted)

A self-provisioning subsystem turns a fresh Linux host into a ready security workstation unattended: staged installs from a data manifest, ordered fallback sources, self-healing error loop, disk planning, and explicit user handoff for blockers.

- `setup` agent (`prompts/agents/setup.md`), inventory data (`prompts/agents/setup-manifest.yaml`), `/setup` command, agent-scoped elevation in `opencode.jsonc`, design doc in `docs/SETUP.md`.
- Iterations tracked there: profile `--dry-run`, checkpoint/resume (`setup/state.json`), teardown/rollback, multi-distro package maps, blueprint/export, sponsor confirmation before exploit-stage, scheduled version-audit.

## Specialist agents (next to build)

- **`foothold` / `exploitation`** — authorized exploitation workflow: given a validated entry point, propose and validate the most reliable path forward, keep within scope. Canonical prompt in `prompts/agents/`.
- **`android` / `mobile`** — dedicated APK static + dynamic analysis pipeline (JADX, MobSF, Frida, mitmproxy). Currently inline; promote to a portable prompt.
- **`cloud`** — cloud/container/K8s assessment with Prowler/ScoutSuite/Trivy/Checkov guidance. Promote to portable.
- **`wireless`** — wireless assessment workflows (quiet scanning, handshake capture, authorized WPA/WEP analysis).
- **`redteam` / `adversary-emulation`** — attacker playbook matching (MITRE ATT&CK mapping between findings, techniques, and detections).

## Evidence & automation

- **Engagement templating** — `PENTAGENT_ENGAGEMENTS_DIR` bootstrap with a pre-filled `scope.md`, `deconfliction.md`, `objectives.md`, acceptance criteria, and a status badge in `README.md` (partly done via `evidence`).
- **Snapshotting** — on engagement close, produce a gzipped archive of the workspace (sanitized + full) for handoff.
- **Findings DB** — normalize findings into YAML/JSON front-matter so reports and dashboards can be generated deterministically.
- **Retest automation** — when remediation notes are recorded, auto-generate the retest checklist per finding.
- **MCP tool bridge** — expose pentest tooling and the engagement workspace over MCP (model-agnostic tool layer). Adopt the `spawn_mcp_agent`-style sandboxed sub-agent pattern (GH05TCREW/PentestAgent) and the RAG-optimizer over a tool/loot corpus.
- **Interactive shells** — teach a `tmux`-based skill for long-lived shell sessions (msfconsole, evil-winrm, impacket) with session capture into `evidence/` (Decepticon-style).

## Research & knowledge

- **CVE watchlist** — a `notes/cve-watchlist.md` that the OSINT/recon agents update from NVD/OSV feeds per engaged tech stack.
- **Tool-availability linter** — now backed by the shared `setup-manifest.yaml`; next step: emit a machine-readable inventory table that audit (`kali-tool-audit`) and provisioner (`setup`) both consume (partial: audit already reports against the manifest).
- **Skill library growth** — `lateral-movement`, `privesc-linux`, `privesc-windows`, `ad-census`, `api-pentest` as portable skills.
- **Causal-reasoning plan graph** — upgrade `planner` to record dependency + disproof edges explicitly (LuaN1ao causal graph), driving "re-open/stop" logic.
- **Adversary-playbook matching** — match engaged tech stack against public adversary playbooks to surface missed detections; feed the report's detection guidance (Decepticon/HiveBreach).

## Reporting

- **Executive one-pager** — optional TLP/audience-aware generator (executive, technical, and sanitized variants).
- **Markdown → DOCX/PDF** — recommend an external renderer (pandoc) and document the command; keep outputs out of Git.
- **Evidence appendix builder** — auto-assemble the appendix from the workspace `evidence/` index with hashes.
- **Compliance mapping** — optionally map findings to frameworks (SOC 2, PCI DSS, NIST 800-53, ISO 27001) when the client requests it.
- **Detection-package toggle** — a `detections/` deliverable (Sigma/SPL/KQL) assembled from each finding's detection guidance.

## Portability & runtime adapters

- **`adapters/` directory** — thin adapters for Claude Code, Gemini CLI, GitHub Copilot CLI, and a generic `custom-api` (per `docs/INTEGRATION.md`).
- **Agent-skill auto-discovery map** — a single `SKILLS.md` index mapping each skill to supported runtimes.
- **Prompt versioning** — semantic-version the canonical prompts so adapters can pin behavior.

## Safety & hygiene

- **`/sanitize` command** — before any Git push or share, scan the workspace for secrets/tokens/private keys/PII and redact them.
- **Scope enforcement hook** — every agent's prompt gets a one-line scope reminder; optionally enforce via runtime permission rules for destructive/offensive tools.