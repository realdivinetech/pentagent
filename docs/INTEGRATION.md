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
