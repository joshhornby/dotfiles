#!/usr/bin/env python3
"""PreToolUse hook: deny a tool call that breaks a house rule.

The main rule is prose. It denies a call when the text it writes reads as AI output.

Adapted from fcakyon/claude-codex-settings plugins/humanize. Changes for this setup:
British spellings added to the word list, an American spelling check added, and the
Codex-only paths dropped.

Where it looks:
  * Markdown files, whole, minus code fences.
  * Code files, only inside comments and docstrings.
  * Bash, only in git commit and gh message text, plus heredoc bodies that cat or tee
    writes to a file.
  * MCP calls, only in fields that hold text for a person to read.

Inline code spans are always removed first, so a name such as the CSS colour property
does not trip the spelling check.

It also blocks the `any` type in new TypeScript. That rule reads the code itself, not
the comments. A line marked `// any: <reason>` passes, so an unavoidable `any` cannot
block every write.
"""
import json
import re
import shlex
import sys
from collections import Counter
from pathlib import Path

# blocked on any hit, each mapped to a plain replacement
SWAP = {
    "leverage": "use", "utilize": "use", "utilise": "use", "plethora": "many",
    "myriad": "many", "delve": "look at", "paradigm": "model", "tapestry": "mix",
    "showcase": "show", "realm": "area", "landscape": "field", "innovative": "new",
    "transformative": "major", "unprecedented": "new", "consolidate": "merge",
    "modernize": "update", "modernise": "update", "streamline": "simplify",
    "establish": "set up", "enhanced": "better", "comprehensive": "full",
    "optimize": "improve", "optimise": "improve", "seamlessly": "drop it",
    "crucially": "drop it", "remarkably": "drop it", "unequivocally": "clearly",
    "revolutionize": "change", "revolutionise": "change", "revolutionising": "changing",
    "manifestation": "sign", "testament": "sign", "underscoring": "showing",
    "symbolizing": "showing", "cultivating": "building", "fostering": "building",
    "encompassing": "covering", "facilitating": "helping", "emphasizing": "showing",
    "embodying": "showing", "underlies": "drives", "enduring": "lasting",
    "nestled": "in", "vibrant": "lively", "game-changing": "big",
    "cutting-edge": "latest", "albeit": "though",
}

# blocked cliches and filler openers, each mapped to a short fix note
PHRASES = [
    (r"ever[- ]evolving", "drop 'ever-evolving'"),
    (r"fast[- ]paced world", "drop 'fast-paced world'"),
    (r"a testament to", "say what it shows"),
    (r"aims to explore", "say 'covers'"),
    (r"it is important to note", "state the point"),
    (r"in conclusion", "drop it"),
    (r"in summary", "drop it"),
    (r"to sum up", "drop it"),
    (r"plays? a \w+ role in shaping", "say what it does"),
]

# fine once, suspect when repeated, flagged at LIMIT or more
LIMIT = 3
OFTEN = ["crucial", "essential", "vital", "significant", "moreover", "furthermore",
         "additionally", "aligns", "explore", "robust"]

# house rule: British spelling in prose, identifiers, and strings
SPELLING = {
    "color": "colour", "colors": "colours", "behavior": "behaviour",
    "behaviors": "behaviours", "favor": "favour", "center": "centre",
    "organize": "organise", "organized": "organised", "organization": "organisation",
    "recognize": "recognise", "recognized": "recognised", "analyze": "analyse",
    "analyzed": "analysed", "initialize": "initialise", "initialized": "initialised",
    "customize": "customise", "summarize": "summarise", "prioritize": "prioritise",
    "canceled": "cancelled", "catalog": "catalogue", "defense": "defence",
    "fulfill": "fulfil", "traveled": "travelled",
}

MARKS = {"—": "em-dash, use a comma or a full stop", "§": "section sign",
         ";": "semicolon, use a full stop or a comma"}

SWAP_RE = re.compile(r"\b(" + "|".join(SWAP) + r")\b", re.IGNORECASE)
OFTEN_RE = re.compile(r"\b(" + "|".join(OFTEN) + r")\b", re.IGNORECASE)
SPELLING_RE = re.compile(r"\b(" + "|".join(SPELLING) + r")\b", re.IGNORECASE)

# groups are the delimiter, the rest of the opening line, and the body
HEREDOC = re.compile(r"<<-?[ \t]*[\"']?([A-Za-z_]\w*)[\"']?([^\n]*)\r?\n(.*?)\r?\n[ \t]*\1[ \t]*$",
                     re.DOTALL | re.MULTILINE)
FIELD_FLAGS = {"-f", "-F", "--field", "--raw-field"}

# only cat and tee put a heredoc body into a file unchanged
SEPARATOR = re.compile(r"\|\||&&|[\n;|&]")
CAT_TEE = re.compile(r"^\s*(cat|tee)\b(.*)$", re.DOTALL)
REDIRECT = re.compile(r"(?<![0-9&])>>?[ \t]*(\"[^\"]*\"|'[^']*'|[^\s'\"|&;<>]+)")

# MCP input keys that hold text for a person to read
TEXT_KEYS = {"body", "text", "markdown_text", "content", "description", "title",
             "comment", "message", "subject", "note", "summary", "rich_text"}

MD_EXT = {".md", ".markdown", ".mdx", ".txt"}
HASH_EXT = {".py", ".sh", ".bash", ".zsh", ".rb", ".yaml", ".yml", ".toml"}
C_EXT = {".js", ".ts", ".jsx", ".tsx", ".c", ".cc", ".cpp", ".h", ".hpp", ".java",
         ".go", ".rs", ".css", ".scss", ".swift", ".kt", ".php"}

TS_EXT = {".ts", ".tsx", ".mts", ".cts"}
ANY_RE = re.compile(r":\s*any\b|\bas\s+any\b|\bany\[\]|<any>|Array<any>")
# escape hatch, so a type that cannot be known does not deny every write
ANY_OK = re.compile(r"//\s*any:")


def strip_code(text):
    """Remove fenced blocks and inline code spans."""
    text = re.sub(r"```.*?```", "", text, flags=re.DOTALL)
    return re.sub(r"`[^`]*`", "", text)


def hash_comments(text):
    """Return docstrings and hash comment tails from a hash-comment language."""
    out = re.findall(r'^[ \t]*[rbuRBU]*"""(.*?)"""', text, flags=re.DOTALL | re.MULTILINE)
    out += re.findall(r"^[ \t]*[rbuRBU]*'''(.*?)'''", text, flags=re.DOTALL | re.MULTILINE)
    out += [m.group(1) for line in text.splitlines() if (m := re.search(r"(?:^|\s)#(.*)", line))]
    return "\n".join(out)


def c_comments(text):
    """Return block comments and double-slash comment tails from a C-style language."""
    out = re.findall(r"/\*(.*?)\*/", text, flags=re.DOTALL)
    out += [m.group(1) for line in text.splitlines() if (m := re.search(r"(?:^|\s)//(.*)", line))]
    return "\n".join(out)


def checked(path, text):
    """Return the text to check for a file type, empty for a type not listed."""
    ext = Path(path).suffix.lower()
    if ext in MD_EXT:
        return strip_code(text)
    if ext in HASH_EXT:
        return strip_code(hash_comments(text))
    if ext in C_EXT:
        return strip_code(c_comments(text))
    return ""


def heredocs(command):
    """Yield each heredoc body with the simple command that opens it."""
    for m in HEREDOC.finditer(command):
        head = SEPARATOR.split(command[: m.start()])[-1] + SEPARATOR.split(m.group(2))[0]
        yield head, m.group(3)


def heredoc_writes(command):
    """Return text from heredoc bodies that cat or tee writes to a file."""
    out = []
    for head, body in heredocs(command):
        if not (writer := CAT_TEE.match(head)):
            continue
        targets = REDIRECT.findall(head)
        if writer.group(1) == "tee":
            targets += [a for a in REDIRECT.sub(" ", writer.group(2)).split() if not a.startswith("-")]
        out += [checked(t.strip("\"'"), body) for t in targets]
    return "\n".join(p for p in out if p)


def bash_text(command):
    """Return message text from a git commit or gh command, else empty."""
    git_commit = re.search(r"\bgit\b[^|&]*\bcommit\b", command)
    gh = re.search(r"\bgh\b", command)
    if not (git_commit or gh):
        return ""
    parts = [body for head, body in heredocs(command) if re.search(r"\b(?:git|gh)\b", head)]
    stripped = HEREDOC.sub(" ", command)
    flags = {"-m", "--message"} if git_commit else set()
    if gh:
        flags |= {"-b", "--body", "-t", "--title"}
    try:
        tokens = shlex.split(stripped, comments=False)
    except ValueError:
        tokens = stripped.split()
    for i, tok in enumerate(tokens):
        key, sep, val = tok.partition("=")
        if tok in flags and i + 1 < len(tokens):
            parts.append(tokens[i + 1])
        elif sep and key in flags:
            parts.append(val)
        elif gh and tok in FIELD_FLAGS and i + 1 < len(tokens):
            field, _, value = tokens[i + 1].partition("=")
            if field in {"body", "title"} and not value.startswith("@"):
                parts.append(value)
    return "\n".join(parts)


def mcp_text(obj):
    """Return values of the text fields inside an MCP tool input."""
    if isinstance(obj, dict):
        items = [v if k.lower() in TEXT_KEYS and isinstance(v, str) else mcp_text(v)
                 for k, v in obj.items()]
    elif isinstance(obj, list):
        items = [mcp_text(v) for v in obj]
    else:
        return ""
    return "\n".join(p for p in items if p)


def extract(tool, tool_input):
    """Return the text to check for a tool call, routed by tool."""
    if tool.startswith("mcp__"):
        return strip_code(mcp_text(tool_input))
    if tool == "Bash":
        command = tool_input.get("command", "")
        return "\n".join(p for p in (strip_code(bash_text(command)), heredoc_writes(command)) if p)
    return checked(tool_input.get("file_path", ""), written(tool_input))


def written(tool_input):
    """Return the text a file-writing tool puts into the file."""
    chunks = [tool_input.get("content", ""), tool_input.get("new_string", "")]
    chunks += [e.get("new_string", "") for e in tool_input.get("edits", []) if isinstance(e, dict)]
    return "\n".join(c for c in chunks if c)


def any_uses(tool_input):
    """Return a note when the new TypeScript declares the any type."""
    path = tool_input.get("file_path", "")
    if Path(path).suffix.lower() not in TS_EXT or path.endswith(".d.ts"):
        return []
    hits = []
    for line in written(tool_input).splitlines():
        stripped = line.strip()
        if stripped.startswith(("//", "*")) or ANY_OK.search(line):
            continue
        if ANY_RE.search(line):
            hits.append(stripped[:60])
    if not hits:
        return []
    more = f" and {len(hits) - 1} more" if len(hits) > 1 else ""
    return [f"`any` type in '{hits[0]}'{more}"]


try:
    data = json.load(sys.stdin)
    tool_input = data.get("tool_input") or {}
    text = extract(data.get("tool_name", ""), tool_input)
except Exception:
    sys.exit(0)

notes = [f"remove {label}" for ch, label in MARKS.items() if ch in text]
notes += [f"'{w}' -> {SWAP[w]}"
          for w in dict.fromkeys(m.group(1).lower() for m in SWAP_RE.finditer(text))]
notes += [f"'{w}' -> '{SPELLING[w]}'"
          for w in dict.fromkeys(m.group(1).lower() for m in SPELLING_RE.finditer(text))]
notes += [note for pat, note in PHRASES if re.search(rf"\b(?:{pat})\b", text, re.IGNORECASE)]
counts = Counter(m.group(1).lower() for m in OFTEN_RE.finditer(text))
notes += [f"'{w}' used {n} times, vary it" for w, n in counts.items() if n >= LIMIT]
code_notes = any_uses(tool_input)
notes += code_notes

if notes:
    reason = ("house rules: " + ", ".join(notes)
              + ". Fix these and call the tool again. The prose checks read markdown, "
                "code comments, and message text.")
    if code_notes:
        reason += (" Find the real type. Mark the line `// any: <reason>` only when no "
                   "real type exists.")
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}))

sys.exit(0)
