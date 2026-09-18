# Contributing to Pentagent

Thanks for considering a contribution. This project is MIT-licensed, and so are contributions.

## License agreement

By submitting code, prompts, documentation, or any other content to this repository — via pull request, commit, or issue attachment — you agree that your contribution is licensed under the **MIT License** terms in the [LICENSE](LICENSE) file, and that the project maintainer(s) may use, modify, and redistribute it accordingly. You keep ownership of your work; you grant the project a perpetual, worldwide, royalty-free license to it.

## Ground rules

- **Authorized use only.** Pentagent is for authorized penetration testing, labs, CTFs, and owned systems. Never contribute features or content whose primary purpose is to evade authorization or harm.
- **No secrets.** Never commit credentials, tokens, keys, client names, or real engagement evidence. Keep target data in gitignored local directories (`engagements/`, `setup/`).
- **Keep it portable.** Core behavior belongs in portable prompts/skills under `prompts/` and `.opencode/skills/`. Runtime-specific wiring belongs in thin adapters only.
- **Keep it validated.** Run `bash scripts/validate.sh` before pushing; the CI workflow runs the same checks on every push and PR.

## How to contribute

1. Fork the repository.
2. Create a feature branch.
3. Make focused changes and run `bash scripts/validate.sh`.
4. Open a pull request describing the change and why.

## Reporting issues

Use the issue template. Include relevant evidence for bugs (exact command, error output, environment) but never client data or secrets.