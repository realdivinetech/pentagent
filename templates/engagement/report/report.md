---
title: "Penetration Test Report — TARGET_SLUG"
subtitle: "Authorized security assessment — Engagement ENGAGEMENT_SLUG"
author: "Pentagent (report-writer) — OPERATOR"
date: YYYY-MM-DD
abstract: |
  Two-to-three sentences: who authorized what, the overall posture, and the
  headline risk. This becomes the cover call-out.
---

# Executive summary

EXEC_SUMMARY — plain language, business-facing: what was tested, the overall
posture, headline findings and their impact in business terms.

| # | Finding | Asset | Severity | CWE |
|---|---------|-------|----------|-----|
| F1 | SHORT_TITLE | ASSET | [Critical]{.critical} | 89 |
| F2 | SHORT_TITLE | ASSET | [High]{.high} | 78 |
| Fn | SHORT_TITLE | ASSET | [Low]{.low} / [Info]{.info} | NNN |

> N findings: **N Critical, N High, N Medium, N Low, N Informational**. Top
> risks: ONE_LINE_PER_TOP_RISK.

# Scope and assumptions

- Authorized assets / rules of engagement (see `../scope.md`, `../deconfliction.md`).
- Time window, methodology references (OWASP / PTES / NIST), exclusions and limitations.

# Methodology

Phases followed and tools used, e.g.: recon → enumeration → hypothesis →
exploitation → validation → critique → reporting. Reference framework used.

# Risk summary

## Findings by severity

| Severity | Count | Assets affected |
|----------|-------|-----------------|
| [Critical]{.critical} | N | … |
| [High]{.high} | N | … |
| [Medium]{.medium} | N | … |
| [Low]{.low} | N | … |
| [Informational]{.info} | N | … |

## Risk register

Prioritized table: `# | Risk | Likelihood | Impact | Priority | Mitigation owner`.

# Detailed findings

For every confirmed/potential finding use this block shape:

## Finding F1 — TITLE

**Status:** [Confirmed]{.confirmed} · **Severity:** [Critical]{.critical} ·
**Asset:** ASSET

**Description** — what and where.

**Root cause** — why it exists.

**Evidence** — exact proof, referencing the appendix (`../evidence/FILE`).

**Reproduction**
```
COMMAND_OR_REQUEST_EXCERPT
```

**Impact** — realistic CIA/business impact, no exaggeration.

**CWE / CVSS** — CWE-NNN; CVSS only when defensible (e.g. `CVSS:3.1/AV:N/...`).

**MITRE ATT&CK** — technique IDs this enables/reflects.

**Detection guidance**
```yaml
# Sigma / SPL / KQL shape a defender would see
```

**Remediation** — concrete fix, prioritized.

**Retest** — how the fix will be verified.

# Strategy map

How the findings chain into real attacker paths (reference the engagement task
tree and ATT&CK mapping). E.g. `F3 login bypass → admin panel → data exfil`.

# Detection guidance summary

Per-finding defender signals and suggested detection rules (Sigma/SPL/KQL).

# Evidence appendix

Raw proof: commands, tool output, requests/responses, hashes, screenshots;
PoC artifacts under `../poctest/`. Reference, don't restate.

# Retest status

What was remediated, what remains, and how each finding will be verified.

# References

- CVE / CWE / advisory / OWASP / NIST links actually consulted.

---

*Prepared by Pentagent (report-writer). Render to styled HTML + PDF:*
```bash
scripts/render-report.sh ../reports/TARGET_SLUG-report.md
```