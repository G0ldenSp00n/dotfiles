-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up a mapping for C/C++ files to launch RemedyBG on <F5>
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.keymap.set("n", "<F5>", function()
      -- Launch remedybg asynchronously and detached to prevent Neovim from freezing
      vim.fn.jobstart({ "remedybg.exe", "debugger/hayden.rdbg" }, { detach = true })
    end, { buffer = true, desc = "Run in RemedyBG" })
  end,
})
