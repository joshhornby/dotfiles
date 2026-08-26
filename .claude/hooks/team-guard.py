#!/usr/bin/env python3
"""Reliability guard for agent-team runs.

Three native events, one script. Pass the event as the first argument.

  taskcreated    Record the task in the run log.
  taskcompleted  Block a completion that carries no evidence.
  teammateidle   Stop a teammate going quiet with work still on the board.

Every check fails open. When the script cannot read the state it needs, it exits 0 and
says nothing. A guard that guesses is worse than no guard.

State and the run log live outside the repository, under the Claude config directory.
"""
import json
import os
import sys
import time
from pathlib import Path

NUDGE_LIMIT = 3
NUDGE_GAP_SECONDS = 300

IDLE_NOTE = (
    "Before you go idle, finish the loop:\n"
    "1. Call TaskList. Claim a task with status pending, no owner and empty "
    "blockedBy. Prefer the lowest ID.\n"
    "2. If your own task is done, set metadata.evidence on it, then set status to "
    "completed.\n"
    "3. Send team-lead a DONE or BLOCKED message. State what is now true and how you "
    "proved it.\n"
    "If you have already done all three and no work is free, go idle again and this "
    "will not stop you."
)


def config_dir():
    return Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude")


def state_dir():
    path = config_dir() / "team-guard"
    path.mkdir(parents=True, exist_ok=True)
    return path


def log(event, data):
    """Append one line to the run log. An audit trail for the leads to read."""
    try:
        record = {"at": time.strftime("%Y-%m-%dT%H:%M:%S"), "event": event}
        for key in ("session_id", "team_name", "teammate_name", "task_id",
                    "task_subject"):
            if data.get(key):
                record[key] = data[key]
        with (state_dir() / "run-log.jsonl").open("a") as handle:
            handle.write(json.dumps(record) + "\n")
    except Exception:
        pass


def load_state(name):
    try:
        return json.loads((state_dir() / name).read_text())
    except Exception:
        return {}


def save_state(name, state):
    try:
        (state_dir() / name).write_text(json.dumps(state))
    except Exception:
        pass


def find_task(team, task_id):
    """Return the stored task, or None when it cannot be read.

    The task list is one JSON file per task under the team directory. A miss means the
    run keeps its tasks somewhere else, so the caller must let the action through.
    """
    if not team or not task_id:
        return None
    root = config_dir() / "tasks" / str(team)
    for candidate in (root / f"{task_id}.json", root / f"task-{task_id}.json"):
        try:
            return json.loads(candidate.read_text())
        except Exception:
            continue
    try:
        for path in root.glob("*.json"):
            body = json.loads(path.read_text())
            if str(body.get("id")) == str(task_id):
                return body
    except Exception:
        return None
    return None


def has_evidence(task):
    metadata = task.get("metadata")
    if not isinstance(metadata, dict):
        return False
    value = metadata.get("evidence") or metadata.get("Evidence")
    return isinstance(value, str) and len(value.strip()) >= 20


def deny(message):
    sys.stderr.write(message + "\n")
    sys.exit(2)


def task_completed(data):
    task = find_task(data.get("team_name"), data.get("task_id"))
    if task is None or has_evidence(task):
        return
    deny(
        "This task has no evidence. Call TaskUpdate and set metadata.evidence first. "
        "Say what you ran and what it proved, such as the test command and its "
        "result. Then mark the task completed. 'It builds' is not evidence that the "
        "behaviour works."
    )


def teammate_idle(data):
    name = data.get("teammate_name") or "teammate"
    key = f"{data.get('session_id', 'session')}::{name}"
    state = load_state("idle-nudges.json")
    record = state.get(key) or {"count": 0, "last": 0}
    now = time.time()
    if record["count"] >= NUDGE_LIMIT or now - record["last"] < NUDGE_GAP_SECONDS:
        return
    state[key] = {"count": record["count"] + 1, "last": now}
    save_state("idle-nudges.json", state)
    deny(IDLE_NOTE)


def main():
    event = (sys.argv[1] if len(sys.argv) > 1 else "").lower()
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)
    log(event, data)
    try:
        if event == "taskcompleted":
            task_completed(data)
        elif event == "teammateidle":
            teammate_idle(data)
    except SystemExit:
        raise
    except Exception:
        sys.exit(0)
    sys.exit(0)


main()
