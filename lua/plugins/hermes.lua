-- Hermes Agent integration.
--
-- Two ways to talk to Hermes from Neovim:
--   1. Native ACP via codecompanion.nvim  ->  <leader>ac  (in-editor chat,
--      streamed responses, tool calls, inline diffs you accept/reject).
--   2. Raw Hermes TUI in a terminal split  ->  <leader>ah  (zero-dependency
--      fallback; just the `hermes` CLI in a window).
--
-- The ACP path talks to `~/.hermes/bin/hermes-acp-nvim`, a wrapper that runs
-- Hermes' bundled `hermes-acp` stdio server with the `acp` Python package
-- (agent-client-protocol==0.9.0) injected on PYTHONPATH. The Homebrew
-- hermes-agent formula ships the ACP adapter code but not that dependency,
-- so the wrapper supplies it. Auth is Hermes' own (~/.hermes/auth.json /
-- config.yaml) -- no API key is passed from Neovim.

local HERMES_ACP = vim.fn.expand("~/.hermes/bin/hermes-acp-nvim")

return {
  "olimorris/codecompanion.nvim",
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Hermes chat (ACP)" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Hermes actions" },
    {
      "<leader>ah",
      function()
        -- Raw Hermes TUI in a right-hand terminal split.
        vim.cmd("botright vsplit | terminal hermes")
        vim.cmd("startinsert")
      end,
      desc = "Hermes chat (terminal TUI)",
    },
  },
  opts = {
    adapters = {
      acp = {
        hermes = function()
          -- Extend the bundled `claude_code` ACP adapter: it launches a bare
          -- command over stdio with no provider-specific auth_method, which
          -- matches how hermes-acp works (it uses its own stored credentials).
          return require("codecompanion.adapters").extend("claude_code", {
            name = "hermes",
            formatted_name = "Hermes",
            commands = {
              default = { HERMES_ACP },
            },
            -- Hermes authenticates itself; don't forward any key from Neovim.
            env = {},
            defaults = {
              -- Verified via the ACP handshake: Hermes advertises a "custom"
              -- auth method backed by the configured runtime credentials
              -- (your local endpoint). CodeCompanion sends an `authenticate`
              -- call with this id before `session/new`.
              auth_method = "custom",
              mcpServers = {},
              timeout = 30000,
            },
          })
        end,
      },
    },
    strategies = {
      chat = { adapter = "hermes" },
      inline = { adapter = "hermes" },
    },
  },
}
