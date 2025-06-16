return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see above for full list of optional dependencies ☝️
  },
  opts = function(_, opts)
    local astrocore = require "astrocore"
    return astrocore.extend_tbl(opts, {
      finder = (astrocore.is_available "snacks.pick" and "snacks.pick")
        or (astrocore.is_available "telescope.nvim" and "telescope.nvim")
        or (astrocore.is_available "fzf-lua" and "fzf-lua")
        or (astrocore.is_available "mini.pick" and "mini.pick"),

      daily_notes = {
        folder = "daily",
      },
      completion = {
        nvim_cmp = astrocore.is_available "nvim-cmp",
        blink = astrocore.is_available "blink",
      },
      workspaces = {
        {
          name = "Project Wormwood",
          path = "~/Nextcloud/Game Development/Project Wormwood/",
        },
      },

      -- see below for full list of options 👇
    })
  end,
}
