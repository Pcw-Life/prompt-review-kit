#!/usr/bin/env bash
# Bootstrap prompt-review scripts into the current repository if missing or outdated.
# Sources from this repo's scripts as the canonical template.
set -euo pipefail

TEMPLATE_ROOT="${TEMPLATE_ROOT:-"$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"}"
TARGET_ROOT="${TARGET_ROOT:-"$PWD"}"

src_script="$TEMPLATE_ROOT/scripts/prompt_chain_review.sh"
src_linter="$TEMPLATE_ROOT/scripts/prompt_linter.py"
src_tests_dir="$TEMPLATE_ROOT/tests/prompts"

trg_script="$TARGET_ROOT/scripts/prompt_chain_review.sh"
trg_linter="$TARGET_ROOT/scripts/prompt_linter.py"
trg_tests_dir="$TARGET_ROOT/tests/prompts"

mkdir -p "$TARGET_ROOT/scripts" "$TARGET_ROOT/tests/prompts"

copy_if_missing_or_older() {
  local src="$1" trg="$2"
  if [[ ! -f "$trg" ]]; then
    cp "$src" "$trg"
    echo "[BOOTSTRAP] Installed: ${trg#$TARGET_ROOT/}"
    return
  fi
  # Compare version header if present, else timestamp
  local src_ver trg_ver
  src_ver=$(grep -E "^# prompt-review version:" "$src" | awk -F: '{print $3}' | xargs || true)
  trg_ver=$(grep -E "^# prompt-review version:" "$trg" | awk -F: '{print $3}' | xargs || true)
  if [[ -n "$src_ver" && -n "$trg_ver" ]]; then
    if [[ "$src_ver" != "$trg_ver" ]]; then
      cp "$src" "$trg"
      echo "[BOOTSTRAP] Updated ${trg#$TARGET_ROOT/} -> version $src_ver"
    fi
  else
    if [[ "$src" -nt "$trg" ]]; then
      cp "$src" "$trg"
      echo "[BOOTSTRAP] Updated ${trg#$TARGET_ROOT/} (newer template)"
    fi
  fi
}

copy_if_missing_or_older "$src_script" "$trg_script"
copy_if_missing_or_older "$src_linter" "$trg_linter"

# Sync tests directory structure (only seed if empty)
if [[ ! -d "$trg_tests_dir/goldens" || -z "$(ls -A "$trg_tests_dir" 2>/dev/null || true)" ]]; then
  mkdir -p "$trg_tests_dir/goldens"
  if [[ -d "$src_tests_dir/goldens" ]]; then
    cp -n "$src_tests_dir/goldens"/*.json "$trg_tests_dir/goldens" 2>/dev/null || true
  fi
  cp -n "$src_tests_dir/golden_tests_scaffold.py" "$trg_tests_dir/golden_tests_scaffold.py" 2>/dev/null || true
  echo "[BOOTSTRAP] Seeded tests/prompts scaffolding"
fi

echo "[BOOTSTRAP] Done"
