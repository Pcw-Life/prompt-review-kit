# Prompt Review Kit

Reusable prompt review tooling for VS Code across repositories.

Contents
- scripts/prompt_chain_review.sh: Runs linter + golden tests
- scripts/prompt_linter.py: Lints prompts for common issues (TODOs, placeholders, token estimate)
- scripts/prompt_review_bootstrap.sh: Copies/updates scripts and tests into a target repo
- tests/prompts/golden_tests_scaffold.py: Minimal golden scaffold
- tests/prompts/goldens/example.json: Example spec
- docs/PROMPT_REVIEW_CHECKLIST.md: Manual review checklist

Quick start
1) Install as your local template source
```bash
# Clone the kit locally where the bootstrap can find it
git clone https://github.com/Pcw-Life/prompt-review-kit.git ~/.prompt-review
# Optional: set env var in your shell profile
export PROMPT_REVIEW_HOME="$HOME/.prompt-review"
```

2) Bootstrap into any repo and run
```bash
# From within your repository
./scripts/prompt_review_bootstrap.sh     # copies/updates runner + linter + tests
./scripts/prompt_chain_review.sh         # runs lint + golden tests
```

VS Code tasks (example)
```jsonc
{
  "version": "2.0.0",
  "tasks": [
    { "label": "Prompt: Bootstrap/Update", "type": "shell", "command": "${workspaceFolder}/scripts/prompt_review_bootstrap.sh" },
    { "label": "Prompt Chain: Review (all)", "type": "shell", "dependsOn": ["Prompt: Bootstrap/Update"], "command": "${workspaceFolder}/scripts/prompt_chain_review.sh" }
  ]
}
```

Show in VS Code Testing panel
- Add pytest + a simple test that runs the linter and scaffold.
- Example test is included in consumer repos; see README in consumer for details.

Updating the kit
- Each script includes a header `# prompt-review version: X.Y.Z`.
- The bootstrap compares versions and updates files in target repos when newer.

Releasing
- Bump the version string in scripts.
- Update CHANGELOG.md with the new version and notes.
- Tag a release:
```bash
git tag -a v1.0.0 -m "prompt-review-kit v1.0.0"
git push origin v1.0.0
```

License
- MIT
