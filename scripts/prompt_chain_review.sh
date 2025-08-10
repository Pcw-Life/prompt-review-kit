#!/usr/bin/env bash
# prompt-review version: 1.0.0
# Run prompt lint + golden tests. Repo-agnostic: expects Prompts/ and tests/prompts/ to exist.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
PROMPTS_DIR="${PROMPTS_DIR:-"$ROOT/Prompts"}"
SCRIPTS_DIR="$ROOT/scripts"
TESTS_DIR="$ROOT/tests/prompts"

if [[ ! -d "$PROMPTS_DIR" ]]; then
  echo "[ERROR] Prompts directory not found at: $PROMPTS_DIR"
  echo "Set PROMPTS_DIR=/path/to/Prompts if your prompts live elsewhere."
  exit 2
fi

# Lightweight venv for deps (optional; falls back to system Python if desired)
VENV_DIR="${VENV_DIR:-"$ROOT/.venv"}"
PYTHON_BIN="${PYTHON_BIN:-"python3"}"

if [[ -d "$VENV_DIR" ]]; then
  source "$VENV_DIR/bin/activate"
else
  if command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    "$PYTHON_BIN" -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    pip install --quiet --upgrade pip
  else
    echo "[WARN] python3 not found; attempting to run without venv."
  fi
fi

# Ensure tiktoken if available; linter tolerates absence
pip install --quiet tiktoken >/dev/null 2>&1 || true

echo "==> Linting prompts"
python "$SCRIPTS_DIR/prompt_linter.py" --prompts "$PROMPTS_DIR"

echo "==> Running golden tests"
python "$ROOT/tests/prompts/golden_tests_scaffold.py" --prompts "$PROMPTS_DIR"

echo "==> Prompt chain review: OK"
