# Pentagent Setup System — design & brainstorm

A self-provisioning subsystem: *"given a fresh Linux box, install everything it needs, give itself the access it needs, fix its own errors, and hand back only what it cannot solve."*

## Design goals

1. **Fresh box → ready box, unattended.** One invocation turns an unprepared system into a complete security workstation.
2. **Self-healing.** Errors are diagnosed, not retried blindly; fallbacks are real and ordered.
3. **Honest blockers.** Disk, sudo, network, hardware, and licensed tools are surfaced precisely for the user — never faked or forced past.
4. **Safe by isolation.** Elevation lives only inside the `setup` agent's wiring, never the global permission map.
5. **Portable + data-driven.** Behavior is a portable prompt; the inventory is plain data (`setup-manifest.yaml`) any AI/agent runtime can read.

## Architecture

```
/setup (command) ──► pentagent (primary) ──► setup subagent (canonical prompt, elevated)
                                              │   reads
                                              ▼
                                      setup-manifest.yaml (data: categories, profiles,
                                              sources+fallbacks, size_mb, verify cmd, host_req)
                                              │   writes
                                              ▼
                                      setup/setup-log.md (gitignored, reproducible)
```

Layering keeps the project's rule: portable prompt in `prompts/agents/`, data beside it, runtime wiring only in the adapter's `agent` map.

## The staged pipeline

| Stage | Purpose | Sample tools |
|-------|---------|--------------|
| **F0 Host gate** | validate before touching anything | passwordless sudo, network, disk, PATH dirs |
| **F1 Foundation** | runtimes & buildics everything depends on | build-essential, git, curl, go, pipx, node, rust, tmux |
| **R2 Recon** | attack-surface discovery | nmap, subfinder, httpx, theHarvester, shodan, amass |
| **W3 Web** | web/API testing | ffuf, nuclei, sqlmap, testssl.sh, seclists |
| **X4 Exploit/creds** | exploitation + credentials + wireless | metasploit, hashcat, john, hydra, searchsploit, aircrack-ng |
| **M5 Mobile** | Android reverse engineering | adb, apktool, jadx, frida, objection, ghidra |
| **C6 Cloud** | cloud/container | awscli, trivy, prowler, scoutsuite, kubectl |
| **D7 AD** | Active Directory/Windows | netexec, impacket, responder, evil-winrm, kerbrute |
| **U8 Utility** | reporting/analysis | pandoc, exiftool, binwalk |
| **V9 Verify + handoff** | audit everything, write the completion report | re-run every `verify` |

Dependencies flow downward (foundation → nothing above depends upward). A later stage can be computed even if a previous one partially failed; only its own prerequisites block it. This mirrors the task-tree idea from the planner agent and PentestGPT's iterative loop.

## The "plan card" (Stage F0)

Before any install, the agent prints: profile, tool count, stage order, `sum(size_mb) + 30% headroom` vs. `df` free space, and failed host requirements. Rationale: the user consented to *provisioning*; consent is renewed per meaningful decision, not per package.

## Self-healing loop (the core of "it solves it itself")

```
attempt(package):
  choose first remaining source (apt/pipx/go/cargo/gem/git)
  run it; capture real error
  if fail: diagnose one line -> apply lowest-impact fix
           (apt update / --fix-broken / pipx switch for PEP-668 /
            PATH symlink / apt search correct package name)
           retry THIS source once
  if still fail: next source in manifest order
  if all sources exhausted: mark BLOCKED with verbatim last error, continue
```

Guardrails: never retry an identical failing command; no `-f` coercion of the OS; no mid-run distro upgrade; three tools blocked by one root cause → stop that stage and surface the cause once.

## "Give itself access" — access normalization

- **PATH**: after foundation, add missing bin dirs (`~/.cargo/bin`, `~/go/bin`, `~/.local/bin`) to the shell rc in one line; refresh session when possible.
- **Groups**: add user to `kali`, `wireshark`, `vboxusers` where the distro implies them (document: effective after re-login).
- **Raw sockets**: prefer distro-standard behavior; do not hand out `setcap` grants the distro doesn't ship.
- **Sudo**: detected at F0; if passwordless sudo is missing the agent stops and hands the exact `visudo` line to the user. This is the one permission the agent refuses to grant itself silently — the user must own it.

## Permission model (OpenCode wiring)

Per-agent `bash` permissions **override** the global map (empirically verified with the capture-test in `/tmp/opencode/permt2`). So:

- Global `permission.bash` keeps `"*": "ask"` and every install gated.
- The `setup` agent alone gets `bash: { "*": "allow", <catastrophic denies last> }`.
- LAST-matching-wins makes the *denies* effective even though allow is the catch-all: `rm -rf /`, `mkfs`, `dd → /dev/sd*`, `fdisk`, `parted`, power-state changes stay refused inside the elevated agent.

Boundary rule (AGENTS.md): the elevation is *agent-scoped*, never global. Any other agent hitting an install still asks.

## Disk planner

The manifest carries `size_mb` per tool; profiles are stage sets. F0 sums the profile and compares to free space + 30% headroom. If short: the agent tells the user what to free (`apt-get clean`, `apt autoremove`, prune snaps/caches) and stops F1 until the user remedies — disk is a genuine blocker. Live tool sizes drift; sizes are estimates that bias generously.

## Things it cannot solve (handed to the user, not faked)

- Passwordless sudo setup (the `visudo` line must be user-given)
- No network / blocked mirrors (proxy or re-run connected)
- Insufficient disk (cleanup guidance)
- GUI/paid tools (Burp, Nessus, Metasploit Pro) — out of scope unless requested
- Hardware presence: Wi-Fi RF dongles, GPU for hashcat, USB — can't be installed
- Non-Debian-branch distros with unmapped package names — stop, note the gap
- New-group membership (effective only after re-login)

## Brainstorm: next iterations

- **Profiles as YAML-first UX** — profile definitions already in the manifest; `/setup webapp` should install only that stage set. Add `--dry-run` printing the plan card without installing.
- **Checkpoint/resume** — a machine-readable state file (`setup/state.json`) so interrupted runs resume at the last failed stage instead of re-validating everything.
- **Undo / rollback** — record every installed package with `apt-mark manual` trick row or `dpkg.log` section so a "teardown" mode can revert to first boot.
- **Multi-distro parity** — parallel `dnf`/`pacman`/`apk` package-name maps in the manifest, selected by `/etc/os-release`.
- **Tool availability linter** — extend `kali-tool-audit` to emit the same machine-readable inventory the setup agent consumes, making "what's missing" and "what will be installed" literally the same query.
- **Blueprint mode** — export the successful run (tool set + versions) as a reusable blueprint / Dockerfile base for reproducible lab images.
- **Sponsor model** — before X4 (exploit) tools, print the tool list and require one user confirmation; exploit stage installs are the highest-impetus-for-consent group.
- **Scheduled self-audit** — a periodic check that runs V9 and says "nuclei is outdated, /setup standard would bump it" — keeps a long-lived workstation fresh.

## Anti-goals

- Never repartition, wipe, or reinstall the OS.
- Never auto-grant passwordless sudo (user-owned decision).
- Never force-install GUI/licensed tools.
- No background "phone home" from the setup log.