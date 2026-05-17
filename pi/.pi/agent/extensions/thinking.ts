import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ThinkingLevel = "off" | "minimal" | "low" | "medium" | "high" | "xhigh";

const LEVELS: ThinkingLevel[] = ["off", "minimal", "low", "medium", "high", "xhigh"];

export default function (pi: ExtensionAPI) {
  // Keep the footer status in sync with the current thinking level.
  function updateStatus(level: ThinkingLevel) {
    pi.ui?.setStatus("thinking", `thinking: ${level}`);
  }

  pi.on("thinking_level_select", async (event, ctx) => {
    ctx.ui.setStatus("thinking", `thinking: ${event.level}`);
  });

  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.setStatus("thinking", `thinking: ${pi.getThinkingLevel()}`);
  });

  pi.registerCommand("thinking", {
    description: "Get or set the thinking level (off | minimal | low | medium | high | xhigh)",
    getArgumentCompletions: (prefix) => {
      const items = LEVELS.map((l) => ({ value: l, label: l }));
      const filtered = items.filter((i) => i.value.startsWith(prefix));
      return filtered.length > 0 ? filtered : null;
    },
    handler: async (args, ctx) => {
      const arg = args?.trim() as ThinkingLevel | undefined;

      if (!arg) {
        const current = pi.getThinkingLevel();
        ctx.ui.notify(`Current thinking level: ${current}`, "info");
        return;
      }

      if (!LEVELS.includes(arg)) {
        ctx.ui.notify(
          `Invalid level "${arg}". Valid levels: ${LEVELS.join(", ")}`,
          "error",
        );
        return;
      }

      pi.setThinkingLevel(arg);
      ctx.ui.notify(`Thinking level set to: ${arg}`, "info");
    },
  });
}
