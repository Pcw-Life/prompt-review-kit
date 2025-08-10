#!/usr/bin/env python3
# Simple scaffold: validates that key strings exist in prompt files per golden spec.
import argparse, json, pathlib, sys


def normalized(s):
    return s.strip().replace("\r\n", "\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompts", type=pathlib.Path, default=pathlib.Path("Prompts"))
    ap.add_argument("--goldens", type=pathlib.Path, default=pathlib.Path("tests/prompts/goldens"))
    args = ap.parse_args()

    if not args.goldens.exists():
        print(f"[WARN] No goldens at {args.goldens}; skipping.")
        return 0

    failures = 0
    for g in sorted(args.goldens.glob("*.json")):
        spec = json.loads(g.read_text())
        prompt_file = args.prompts / spec["prompt_file"]
        if not prompt_file.exists():
            print(f"[FAIL] {g.name}: prompt file not found {prompt_file}")
            failures += 1
            continue

        # For now: simple "must include" checks against prompt text.
        actual = normalized(prompt_file.read_text())
        for must in spec.get("must_include", []):
            if must not in actual:
                print(f"[FAIL] {g.name}: missing '{must}' in {prompt_file.name}")
                failures += 1

    if failures:
        print(f"[FAIL] Golden tests failed: {failures} issues")
        return 1
    print("[OK] Golden tests passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
