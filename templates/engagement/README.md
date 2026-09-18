# Engagement template

Blank, copy-able engagement workspace scaffold. Copy this directory to
`<engagements-dir>/<slug>/` at the start of every engagement (preferred slug:
`YYYY-MM-DD-<target-normalized>`), then fill placeholders.

Copy with:

    cp -r templates/engagement "engagements/$(date +%Y-%m-%d)-<slug>"

Layout (matches the `evidence` agent's expectations):

```
engagement/
├── README.md            # index: target, dates, status, phase tracker
├── scope.md             # authorized scope + rules of engagement
├── deconfliction.md     # boundaries, stop conditions, contacts
├── objectives.md        # goals + acceptance criteria
├── tasks.md             # phase task tree (planner-owned)
├── attack-chains.md     # MITRE ATT&CK kill-chain map (planner-owned)
├── findings/            # one file per finding (critic-verified)
├── evidence/            # raw confirmed proof: requests, hashes, logs
├── recon/               # raw scans/tool output
├── osint/               # OSINT artifacts
├── notes/               # timeline, hypotheses
└── report/              # final reports (Markdown + rendered)
```

Rules that apply to every engagement: never commit the workspace to
Git if it contains real target data; keep raw evidence separate from
interpretation; never mark findings Confirmed yourself — the `critic`
rules.