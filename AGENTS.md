# Pentagent Project Instructions

Pentagent is a modular personal penetration-testing and security-research agent.

## Canonical source

The canonical behavioral prompt is:

`prompts/pentagent-system.md`

Keep provider/runtime adapters thin. Do not duplicate the full prompt into multiple files unless a runtime requires it.

## Project rules

- Never commit credentials, tokens, private keys, client secrets, cookies, or real sensitive evidence.
- Keep engagement data under ignored/local directories unless deliberately sanitized.
- Prefer reproducible commands and record important evidence.
- Do not fabricate findings or tool output.
- Installation of new software requires user approval.
  Exception: the `setup` provisioner agent is explicitly authorized to install and self-heal unattended (see `prompts/agents/setup.md`). Its grants exist only in its own agent wiring, never in the global permission map.
- Treat scope as a hard boundary.
- Keep destructive/system-sensitive operations approval-gated or blocked.

## Specialist agents

Canonical specialist prompts live in `prompts/agents/` (portable, runtime-agnostic) and are wired into each runtime:

- `osint` — open-source intelligence (`prompts/agents/osint.md`)
- `evidence` — engagement/evidence keeper (`prompts/agents/evidence.md`)
- `planner` — engagement strategist: task tree + ATT&CK kill-chain map (`prompts/agents/planner.md`)
- `critic` — validation gate / false-positive review (`prompts/agents/critic.md`)
- `report-writer` — professional reporting (`prompts/agents/report-writer.md`)
- `setup` — provisioner: bootstraps a fresh Linux host into a ready security workstation (`prompts/agents/setup.md`, inventory in `prompts/agents/setup-manifest.yaml`)

Add new specialists by creating a prompt in `prompts/agents/` and wiring it per runtime; do not duplicate the full prompt across runtime files.

## Development model

Build Pentagent in layers:

1. Portable core prompt
2. OpenCode runtime adapter
3. Specialist agents/skills
4. Engagement/evidence structure
5. Additional AI-tool adapters
6. Optional MCP/tool integrations

The repository must remain usable without OpenCode-specific features.
