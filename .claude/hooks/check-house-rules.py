#!/usr/bin/env python3
"""PostToolUse hook: warn (never block) when an edited file breaks a house rule.

Fires after Edit/Write/MultiEdit. Warn-only — always exits 0 and surfaces findings
back to Claude as additionalContext so it can self-correct on the next turn.

Checks:
  * Code files (.ts/.tsx/.js/.jsx): use of the `any` type.
  * Prose files (.md/.mdx/.txt): a small set of American spellings.

To make this BLOCKING later, change `exit(0)` at the bottom to emit
{"decision": "block", "reason": ...} — but leave it warn-only until it's proven noisy-free.
"""
import json
import re
import sys

try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool_input = payload.get("tool_input", {}) or {}
path = tool_input.get("file_path") or tool_input.get("path") or ""
if not path:
    sys.exit(0)

try:
    with open(path, "r", encoding="utf-8") as fh:
        text = fh.read()
except Exception:
    sys.exit(0)

lines = text.splitlines()
warnings = []

CODE_EXT = (".ts", ".tsx", ".js", ".jsx")
PROSE_EXT = (".md", ".mdx", ".txt")

# --- `any` type usage in code files ---
if path.endswith(CODE_EXT):
    any_pat = re.compile(r"(:\s*any\b|\bas\s+any\b|\bany\[\]|<any>|Array<any>)")
    for i, line in enumerate(lines, 1):
        # skip line/block comment lines to cut noise
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith("*"):
            continue
        if any_pat.search(line):
            warnings.append(f"  L{i}: `any` type — {stripped[:80]}")
    if warnings:
        warnings.insert(0, "Uses of `any` (house rule: never `any`, find the real type):")

# --- American spelling in prose files ---
elif path.endswith(PROSE_EXT):
    us_uk = {
        r"\bcolor\b": "colour", r"\bbehavior\b": "behaviour",
        r"\bfavor\b": "favour", r"\bcenter\b": "centre",
        r"\borganiz(e|ed|ing|ation)\b": "organis-", r"\brecogniz(e|ed|ing)\b": "recognis-",
        r"\boptimiz(e|ed|ing|ation)\b": "optimis-", r"\bcanceled\b": "cancelled",
        r"\bcatalog\b": "catalogue", r"\blicense\b (verb)": "licence",
    }
    hits = []
    for pat, uk in us_uk.items():
        rx = re.compile(pat, re.IGNORECASE)
        for i, line in enumerate(lines, 1):
            if rx.search(line):
                hits.append(f"  L{i}: American spelling (use British ~ {uk})")
                break
    if hits:
        warnings.append("Possible American spellings (house rule: British spelling):")
        warnings.extend(hits)

if warnings:
    msg = f"[house-rules] {path}\n" + "\n".join(warnings)
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": msg,
        }
    }))

sys.exit(0)
