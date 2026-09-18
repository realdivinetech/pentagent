# Using Pentagent with other AI tools

Pentagent is intentionally designed so the core intelligence is not locked to OpenCode.

## Canonical prompts

Use these as the source of truth:

- `prompts/pentagent-system.md` — primary operator behavior.
- `prompts/agents/osint.md` — OSINT specialist.
- `prompts/agents/evidence.md` — engagement/evidence keeper.
- `prompts/agents/report-writer.md` — report specialist.

## Runtime adapter pattern

For any other AI agent runtime:

1. Load `prompts/pentagent-system.md` as the system/developer instruction.
2. Load the relevant `prompts/agents/*.md` as system instructions for the corresponding subagent/specialist.
3. Expose the runtime's shell/file/web tools as appropriate.
4. Preserve the installation-approval rule.
5. Preserve the scope/evidence rules.
6. Preserve the distinction between tool output and conclusions.
7. Keep secrets and engagement evidence out of the public repository.
8. Point the evidence keeper at an engagement workspace (`PENTAGENT_ENGAGEMENTS_DIR`, default `<project>/engagements`).

## Published vs. local (OpenCode adapter)

The **analyze repo** publishes only the portable core (`prompts/`, `docs/`,
`scripts/`, `templates/`). The OpenCode runtime wiring — `.opencode/`
(commands, agents wrappers, skills) and `opencode.jsonc` (permission model) —
is **local and git-ignored**: the human runs it on their own machine, and the
specific permissions each operator accepts stay off GitHub. When you bulk
`opencode.jsonc` locally, start from a normal OpenCode config and wire the
specialist prompts in `prompts/agents/` as described above; keep the global
bash permission gated (`"*": "ask"`) and grant per-agent elevations only where
you deliberately want them (see `docs/SETUP.md` for the setup-agent
supervised/scoped model).

## Quick adapter examples

**Claude Code** (CLI). Load the system prompt and give it the repo as context:
```bash
claude --system "$(cat prompts/pentagent-system.md)" --allowed-tools "Bash(.*),Read,Write" .
# add specialist subagents in .claude/agents/*.md pointing at prompts/agents/*.md
```

**Gemini CLI**. `gemini` picks up `AGENTS.md`; then start the session in-project
with the system prompt:
```bash
gemini --prompt "$(cat prompts/pentagent-system.md) Follow it for this session."
```

**Cursor / IDE agents**. Paste `prompts/pentagent-system.md` into the project
agent instructions, or reference it in `.cursor/rules`, and wire the specialist
prompts as subagents/skills the same way.

**Any remote/custom LLM**. Send `prompts/pentagent-system.md` as the system
message; attach the relevant `prompts/agents/*.md` when delegating to that
specialist; keep the scope, approval, and evidence rules intact.

In every runtime the operational loop is the same:
`/setup`-equivalent provisioning → `/engage` workspace → recon → test →
`/critique` validation → `/report`. Only the loading mechanism differs.

## Future adapters

A future version can add files such as:

```text
adapters/
├── opencode/
├── claude-code/
├── gemini-cli/
└── custom-api/
```

Each adapter should reference or embed the canonical prompt only as required by the target runtime.
