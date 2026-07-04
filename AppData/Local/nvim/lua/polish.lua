-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up mappings for C/C++ files to control RemedyBG
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    local remedybg_exe = "C:/Users/spoon/Downloads/remedybg_0_3_6_4/remedybg.exe"

    -- F5: Start Debugging
    vim.keymap.set("n", "<F5>", function()
      vim.fn.jobstart({ remedybg_exe, "start-debugging" }, { detach = true })
    end, { buffer = true, desc = "Start Debugging in RemedyBG" })

    -- Shift+F5: Stop Debugging
    vim.keymap.set("n", "<S-F5>", function()
      vim.fn.jobstart({ remedybg_exe, "stop-debugging" }, { detach = true })
    end, { buffer = true, desc = "Stop Debugging in RemedyBG" })

    -- F6: Restart Debugging (Stop then Start)
    vim.keymap.set("n", "<F6>", function()
      -- Use vim.system to ensure the stop command completely finishes sending before starting
      vim.system({ remedybg_exe, "stop-debugging" }, { text = true }, function()
        -- Add a tiny delay to give RemedyBG time to fully process the stop internally
        vim.defer_fn(function()
          vim.fn.jobstart({ remedybg_exe, "start-debugging" }, { detach = true })
        end, 200)
      end)
    end, { buffer = true, desc = "Restart Debugging in RemedyBG" })
  end,
})
