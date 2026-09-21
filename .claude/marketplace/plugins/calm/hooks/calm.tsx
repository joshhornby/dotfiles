import type { Register } from "claude-code";

type Mode = "off" | "normal" | "zen";

const modes: readonly Mode[] = ["off", "normal", "zen"];

const isMode = (value: unknown): value is Mode =>
  typeof value === "string" && (modes as readonly string[]).includes(value);

const field = ({ input, key }: { input: unknown; key: string }): string | undefined => {
  if (typeof input !== "object" || input === null) return undefined;
  const value: unknown = Reflect.get(input, key);
  return typeof value === "string" && value.length > 0 ? value : undefined;
};

const basename = (path: string): string => path.split("/").filter(Boolean).pop() ?? path;

const shorten = (text: string): string => {
  const line = text.split("\n")[0] ?? "";
  return line.length > 60 ? `${line.slice(0, 57)}...` : line;
};

type Verb = { present: string; past: string };

const describe = ({ tool, input }: { tool: string; input: unknown }): Verb => {
  const path = field({ input, key: "file_path" }) ?? field({ input, key: "notebook_path" });
  const target = path ? ` ${basename(path)}` : "";
  switch (tool) {
    case "Read":
      return { present: `Reading${target}`, past: `Read${target}` };
    case "Edit":
    case "MultiEdit":
    case "NotebookEdit":
      return { present: `Editing${target}`, past: `Edited${target}` };
    case "Write":
      return { present: `Writing${target}`, past: `Wrote${target}` };
    case "Bash": {
      const what = shorten(field({ input, key: "description" }) ?? field({ input, key: "command" }) ?? "command");
      return { present: `Running ${what}`, past: `Ran ${what}` };
    }
    case "Grep":
    case "Glob":
      return { present: "Searching the codebase", past: "Searched the codebase" };
    case "Agent":
    case "Task":
      return { present: "Delegating to an agent", past: "Delegated to an agent" };
    case "WebFetch":
    case "WebSearch":
      return { present: "Researching the web", past: "Researched the web" };
    default:
      return { present: `Using ${tool}`, past: `Used ${tool}` };
  }
};

export const register: Register = (on) => {
  let mode: Mode = "normal";

  on("session.start", async ($, e, next) => {
    const stored = await $.store.get("mode");
    if (isMode(stored)) mode = stored;
    await $.command.register({
      name: "calm",
      description: "Set how much tool activity Claude Code shows",
      argumentHint: "[off|normal|zen]",
      immediate: true,
    });
    return next(e);
  });

  on("command.run", { command: "calm" }, async ($, e) => {
    const requested = e.args.trim();
    if (requested === "") return { text: `Mode: ${mode}. Use /calm off, /calm normal or /calm zen.` };
    if (!isMode(requested)) return { text: `Unknown mode "${requested}". Use off, normal or zen.` };
    mode = requested;
    await $.store.set("mode", mode);
    if (mode === "off") $.ui.status(undefined);
    // Render answers are cached per input, so rows already on screen keep the old mode until invalidated.
    $.ui.invalidate("ui.render");
    return { text: `Mode: ${mode}.` };
  });

  on("tool.call", async ($, e, next) => {
    // A subagent's calls would make the status line flicker between two streams of work.
    if (mode === "off" || e.agentId !== undefined) return next(e);
    $.ui.status(describe({ tool: e.tool, input: e }).present);
    return next(e);
  });

  on("turn.complete", ($, e, next) => {
    $.ui.status(undefined);
    return next(e);
  });

  on("ui.render", { component: "ToolUse" }, ($, e, next) => {
    const { tool, input, isRunning, isErrored, isInterrupted } = e.props;
    if (mode === "off" || isErrored || isInterrupted) return next(e);
    const { Box, Text } = $.ui.resolve(e);
    if (mode === "zen" || isRunning) return <Box />;
    return (
      <Box>
        <Text color="green">✓ </Text>
        <Text dimColor>{describe({ tool, input }).past}</Text>
      </Box>
    );
  });

  on("ui.render", { component: "ToolResult" }, ($, e, next) => {
    if (mode === "off" || e.props.isErrored) return next(e);
    const { Box } = $.ui.resolve(e);
    return <Box />;
  });

  on("ui.render", { component: "ToolGroup" }, ($, e, next) => {
    if (mode !== "zen" || e.props.calls.some((call) => call.isErrored)) return next(e);
    const { Box } = $.ui.resolve(e);
    return <Box />;
  });

  on("ui.render", { component: "TurnDuration" }, ($, e, next) => {
    if (mode !== "zen") return next(e);
    const { Box } = $.ui.resolve(e);
    return <Box />;
  });
};
