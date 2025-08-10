#!/usr/bin/env python3
# prompt-review version: 1.0.0
import argparse, re, sys, pathlib

BAD_MARKERS = [r"\bTODO\b", r"\bTBD\b", r"\[INSERT.*?\]", r"lorem ipsum"]
PLACEHOLDER = re.compile(r"\{\{[^}]+\}\}")  # {{var}}


def maybe_encoder():
    try:
        import tiktoken
        return tiktoken.get_encoding("cl100k_base")
    except ImportError:
        return None


def count_tokens(enc, text):
    if not enc:
        return None
    return len(enc.encode(text))


def main():
    ap = argparse.ArgumentParser(description="Lint prompt files for common issues.")
    ap.add_argument("--prompts", type=pathlib.Path, default=pathlib.Path("Prompts"),
                    help="Path to Prompts directory")
    ap.add_argument("--warn-tokens", type=int, default=3000,
                    help="Warn if prompt exceeds this many tokens")
    args = ap.parse_args()

    enc = maybe_encoder()
    prompts_dir = args.prompts
    if not prompts_dir.exists():
        print(f"[ERROR] Prompts directory not found: {prompts_dir}", file=sys.stderr)
        return 2

    ok = True
    files = sorted(prompts_dir.glob("*.md"))
    if not files:
        print(f"[WARN] No prompt files found in {prompts_dir}")
    for p in files:
        text = p.read_text(encoding="utf-8")
        for pat in BAD_MARKERS:
            if re.search(pat, text, flags=re.IGNORECASE):
                print(f"[FAIL] {p.name}: found marker matching /{pat}/")
                ok = False
        for m in PLACEHOLDER.findall(text):
            print(f"[WARN] {p.name}: placeholder present {m} (ensure runtime fills it)")
        toks = count_tokens(enc, text)
        if toks and toks > args.warn_tokens:
            print(f"[WARN] {p.name}: large prompt ~{toks} tokens")

        # Minimal schema hints
        if "Goal" not in text:
            print(f"[WARN] {p.name}: missing 'Goal' section")
        if "Steps" not in text:
            print(f"[WARN] {p.name}: missing 'Steps' section")

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
