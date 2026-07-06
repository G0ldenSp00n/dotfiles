-- You can also add or configure plugins by creating files in this `plugins/` folder
-- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- Here are some examples:

local function async_build(cmd, path_pattern, desc)
  return {
    function()
      if not vim.fn.getcwd():match("project%-wormwood%-engine") then return end
      
      -- Automatically save all unsaved buffers before building
      vim.cmd("silent! wa")
      
      vim.notify("Building " .. desc .. "...", vim.log.levels.INFO)
      
      -- Function to actually run the build
      local run_build = function()
        local efm = "%f(%l): %trror %m,%f(%l): %tarning %m,%f(%l): %m,%f(%l): note: %m,ERROR: %f:%l: %m,WARNING: %f:%l: %m"
        
        -- Open quickfix immediately
        vim.fn.setqflist({}, "r", { lines = {}, efm = efm, title = desc .. " Output" })
        vim.cmd("copen")
        
        local buffer = ""
        local on_data = function(err, data)
          if not data then return end
          vim.schedule(function()
            buffer = buffer .. data
            local lines = {}
            while true do
              local nl = buffer:find("\n")
              if not nl then break end
              local line = buffer:sub(1, nl - 1):gsub("\r$", "")
              buffer = buffer:sub(nl + 1)
              
              local fixed = line:gsub(path_pattern, "src\\")
              fixed = fixed:gsub("ERROR: " .. path_pattern, "ERROR: src\\")
              fixed = fixed:gsub("WARNING: " .. path_pattern, "WARNING: src\\")
              table.insert(lines, fixed)
            end
            
            if #lines > 0 then
              vim.fn.setqflist({}, "a", { lines = lines, efm = efm })
              -- Scroll to bottom
              local qf_win = vim.fn.getqflist({ winid = 0 }).winid
              if qf_win ~= 0 then
                local buf = vim.api.nvim_win_get_buf(qf_win)
                vim.api.nvim_win_set_cursor(qf_win, { vim.api.nvim_buf_line_count(buf), 0 })
              end
            end
          end)
        end

        vim.system({ "cmd.exe", "/c", cmd }, { 
          stdout = on_data,
          stderr = on_data
        }, function(obj)
          vim.schedule(function()
            if buffer ~= "" then
              local fixed = buffer:gsub("\r$", ""):gsub(path_pattern, "src\\")
              fixed = fixed:gsub("ERROR: " .. path_pattern, "ERROR: src\\")
              fixed = fixed:gsub("WARNING: " .. path_pattern, "WARNING: src\\")
              vim.fn.setqflist({}, "a", { lines = { fixed }, efm = efm })
              local qf_win = vim.fn.getqflist({ winid = 0 }).winid
              if qf_win ~= 0 then
                local buf = vim.api.nvim_win_get_buf(qf_win)
                vim.api.nvim_win_set_cursor(qf_win, { vim.api.nvim_buf_line_count(buf), 0 })
              end
            end
            if obj.code == 0 then
              vim.notify(desc .. " successful!", vim.log.levels.INFO)
            else
              vim.notify(desc .. " failed. Check Quickfix list.", vim.log.levels.ERROR)
            end
          end)
        end)
      end

      -- Check if RemedyBG is running before trying to stop it
      vim.system({ "tasklist", "/FI", "IMAGENAME eq remedybg.exe" }, { text = true }, function(tasklist_obj)
        if tasklist_obj.stdout and tasklist_obj.stdout:match("remedybg%.exe") then
          vim.schedule(function()
            -- Auto-stop RemedyBG to ensure it releases the executable lock
            vim.fn.jobstart({ "C:/Users/spoon/Downloads/remedybg_0_3_6_4/remedybg.exe", "stop-debugging" }, { detach = true })
            -- Small delay to let RemedyBG fully detach before we start compiling
            vim.defer_fn(run_build, 35)
          end)
        else
          vim.schedule(run_build)
        end
      end)
    end,
    desc = desc,
  }
end

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<F8>"] = async_build(".\\build.bat", "^%.%.[/\\]src[/\\]", "Engine Code"),
          ["<F9>"] = async_build(".\\build_shaders.bat", "^%.%.[/\\]%.%.[/\\]src[/\\]", "Shaders"),
          
          -- Jump through errors easily
          ["]q"] = { "<cmd>cnext<CR>", desc = "Next build issue" },
          ["[q"] = { "<cmd>cprev<CR>", desc = "Previous build issue" },
        },
      },
    },
  },

 {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣠⣤⣤⣼⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀",
            "⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀",
            "⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠘⣿⣿⣿⣿⠟⠁⠀⠀⠀⠹⣿⣿⣿⣿⣿⠟⠁⠀⠀⠹⣿⣿⡿⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⢼⣿⠀⢿⣿⣿⣿⣿⠀⣾⣷⠀⠀⢿⣿⣷⠀⠀⠀⠀⠀",
            "⠀⠀⠀⢠⣿⣿⣿⣷⡀⠀⠀⠈⠋⢀⣿⣿⣿⣿⣿⡀⠙⠋⠀⢀⣾⣿⣿⠀⠀⠀⠀⠀",
            "⢀⣀⣀⣀⣿⣿⣿⣿⣿⣶⣶⣶⣶⣿⣿⣿⣿⣾⣿⣷⣦⣤⣴⣿⣿⣿⣿⣤⠤⢤⣤⡄",
            "⠈⠉⠉⢉⣙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣀⣀⣀⡀⠀",
            "⠐⠚⠋⠉⢀⣬⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣥⣀⡀⠈⠀⠈⠛",
            "⠀⠀⠴⠚⠉⠀⠀⠀⠉⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠋⠁⠀⠀⠀⠉⠛⠢⠀⠀",
            "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀",
            "⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀      ",
          }, "\n"),
        },
      },
    },
  } 
}
