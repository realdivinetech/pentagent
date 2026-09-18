# Engagements workspace

This directory holds all working data collected about your authorized targets.

**Never commit secrets or real client evidence to Git.**
Subdirectories under each engagement are git-ignored by default.

## Layout

```text
engagements/
└── <slug>/                        # e.g. acme-corp
    ├── README.md                  # engagement index: target, dates, status
    ├── scope.md                   # authorized scope + rules of engagement
    ├── recon/                     # raw tool output, scans
    ├── osint/                     # open-source intelligence artifacts
    ├── evidence/                  # confirmed proof: requests, hashes, screenshots, logs
    ├── findings/                  # one file per confirmed/potential finding
    ├── notes/                     # hypotheses, timeline, brainstorm
    └── reports/                   # generated reports
```

## How to start an engagement

Use the `evidence` subagent (canonical prompt: `prompts/agents/evidence.md`), or run `/engage <slug>` from the TUI. The keeper creates the folder structure and a `scope.md` from the authorization you provide.

## Overriding the workspace location

Set the `PENTAGENT_ENGAGEMENTS_DIR` environment variable to store engagement data outside the project tree, e.g.:

```bash
export PENTAGENT_ENGAGEMENTS_DIR=/home/divine/Pentagent-engagements
```

If unset, the workspace defaults to `engagements/` in this project.