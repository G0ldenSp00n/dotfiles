-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up a mapping for C/C++ files to launch RemedyBG on <F5>
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.keymap.set("n", "<F5>", function()
      local rdbg_files = vim.fn.glob("*.rdbg", false, true)
      if #rdbg_files > 0 then
        -- Open the first .rdbg session file found in the current directory
        vim.cmd('silent !start remedybg.exe ' .. vim.fn.shellescape(rdbg_files[1]))
      else
        -- Just start remedybg if no session file exists
        vim.cmd('silent !start remedybg.exe')
      end
    end, { buffer = true, desc = "Run in RemedyBG" })
  end,
})
