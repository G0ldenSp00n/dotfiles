local remedybg_exe = "C:/Users/spoon/Downloads/remedybg_0_3_6_4/remedybg.exe"

local function in_engine()
  return (vim.fn.getcwd():match("project%-wormwood%-engine") ~= nil)
    or (vim.fn.getcwd():match("stt%-engine%-fork") ~= nil)
end

local function focus_game()
  local ps_cmd = [[
    $proc = $null
    for ($i=0; $i -lt 20; $i++) {
      $proc = Get-Process win32_project-wormwood -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($proc) { break }
      Start-Sleep -Milliseconds 100
    }
    if ($proc) {
      $wshell = New-Object -ComObject wscript.shell
      $wshell.AppActivate($proc.Id)
    }
  ]]
  vim.fn.jobstart({ "powershell", "-NoProfile", "-WindowStyle", "Hidden", "-Command", ps_cmd }, { detach = true })
end

local function async_build(cmd, path_pattern, desc)
  return {
    function()
      if not in_engine() then return end
      
      local is_auto = vim.g.auto_build_triggered
      vim.g.auto_build_triggered = false
      
      if not is_auto then
        -- Automatically save all unsaved buffers before building
        vim.g.is_building = true
        vim.cmd("silent! wa")
        vim.g.is_building = false
      end
      
      vim.notify("Building " .. desc .. "...", vim.log.levels.INFO)
      
      local run_build = function()
        local efm = "%f(%l): %trror %m,%f(%l): %tarning %m,%f(%l): %m,%f(%l): note: %m,ERROR: %f:%l: %m,WARNING: %f:%l: %m"
        
        vim.fn.setqflist({}, "r", { lines = {}, efm = efm, title = desc .. " Output" })
        if not is_auto then
          vim.cmd("copen")
        end
        
        local buffer = ""
        local all_lines = {}
        local path_pattern_unanchored = path_pattern:gsub("^%^", "")
        local cwd = vim.fn.getcwd():gsub("\\", "/")
        local src_abs = (cwd .. "/src/"):gsub("%%", "%%%%")
        
        local on_data = function(err, data)
          if not data then return end
          vim.schedule(function()
            buffer = buffer .. data
            local new_lines = {}
            while true do
              local nl = buffer:find("\n")
              if not nl then break end
              local line = buffer:sub(1, nl - 1):gsub("\r$", "")
              buffer = buffer:sub(nl + 1)
              
              local fixed = line:gsub("\\", "/")
              fixed = fixed:gsub(path_pattern, src_abs)
              fixed = fixed:gsub("ERROR: " .. path_pattern_unanchored, "ERROR: " .. src_abs)
              fixed = fixed:gsub("WARNING: " .. path_pattern_unanchored, "WARNING: " .. src_abs)
              table.insert(new_lines, fixed)
              table.insert(all_lines, fixed)
            end
            
            if #new_lines > 0 then
              -- Use 'a' during stream for performance and smooth scrolling
              vim.fn.setqflist({}, "a", { lines = new_lines, efm = efm })
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
              local fixed = buffer:gsub("\r$", ""):gsub("\\", "/")
              fixed = fixed:gsub(path_pattern, src_abs)
              fixed = fixed:gsub("ERROR: " .. path_pattern_unanchored, "ERROR: " .. src_abs)
              fixed = fixed:gsub("WARNING: " .. path_pattern_unanchored, "WARNING: " .. src_abs)
              table.insert(all_lines, fixed)
            end
            
            -- Final full replace to trigger quickfix-to-diagnostic plugins properly
            vim.fn.setqflist({}, "r", { lines = all_lines, efm = efm, title = desc .. " Output" })
            local qf_win = vim.fn.getqflist({ winid = 0 }).winid
            if qf_win ~= 0 then
              local buf = vim.api.nvim_win_get_buf(qf_win)
              vim.api.nvim_win_set_cursor(qf_win, { vim.api.nvim_buf_line_count(buf), 0 })
            end
            
            if obj.code == 0 then
              vim.notify(desc .. " successful!", vim.log.levels.INFO)
            else
              vim.notify(desc .. " failed. Check Quickfix list.", vim.log.levels.ERROR)
            end
          end)
        end)
      end

      vim.system({ "tasklist", "/FI", "IMAGENAME eq remedybg.exe" }, { text = true }, function(tasklist_obj)
        if tasklist_obj.stdout and tasklist_obj.stdout:match("remedybg%.exe") then
          vim.schedule(function()
            vim.fn.jobstart({ remedybg_exe, "stop-debugging" }, { detach = true })
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

local function auto_build(key)
  return function()
    if not in_engine() then return end
    if vim.g.is_building then return end

    local qf_open = false
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "quickfix" then
        qf_open = true
        break
      end
    end

    local has_errors = false
    if qf_open then
      for _, item in ipairs(vim.fn.getqflist()) do
        if item.valid == 1 then
          has_errors = true
          break
        end
      end
    end

    if qf_open and has_errors then
      vim.schedule(function()
        vim.g.auto_build_triggered = true
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "m", false)
      end)
    end
  end
end

return {
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<F5>"] = {
            function()
              if not in_engine() then return end
              vim.system({ "tasklist", "/FI", "IMAGENAME eq remedybg.exe" }, { text = true }, function(tasklist_obj)
                if tasklist_obj.stdout and tasklist_obj.stdout:match("remedybg%.exe") then
                  vim.schedule(function()
                    vim.fn.jobstart({ remedybg_exe, "start-debugging" }, { detach = true })
                    focus_game()
                  end)
                else
                  vim.schedule(function()
                    vim.fn.jobstart({ remedybg_exe, "debugger/hayden.rdbg" }, { detach = true })
                    vim.defer_fn(function()
                      vim.fn.jobstart({ remedybg_exe, "start-debugging" }, { detach = true })
                      focus_game()
                    end, 300)
                  end)
                end
              end)
            end,
            desc = "Start Debugging in RemedyBG"
          },
          ["<S-F5>"] = {
            function()
              if not in_engine() then return end
              vim.system({ "tasklist", "/FI", "IMAGENAME eq remedybg.exe" }, { text = true }, function(tasklist_obj)
                if tasklist_obj.stdout and tasklist_obj.stdout:match("remedybg%.exe") then
                  vim.schedule(function() vim.fn.jobstart({ remedybg_exe, "stop-debugging" }, { detach = true }) end)
                end
              end)
            end,
            desc = "Stop Debugging in RemedyBG"
          },
          ["<F6>"] = {
            function()
              if not in_engine() then return end
              vim.system({ "tasklist", "/FI", "IMAGENAME eq remedybg.exe" }, { text = true }, function(tasklist_obj)
                if tasklist_obj.stdout and tasklist_obj.stdout:match("remedybg%.exe") then
                  vim.schedule(function()
                    vim.system({ remedybg_exe, "stop-debugging" }, { text = true }, function()
                      vim.defer_fn(function()
                        vim.fn.jobstart({ remedybg_exe, "start-debugging" }, { detach = true })
                        focus_game()
                      end, 200)
                    end)
                  end)
                end
              end)
            end,
            desc = "Restart Debugging in RemedyBG"
          },
          ["<F8>"] = async_build(".\\build.bat", "^%.%./src/", "Engine Code"),
          ["<F9>"] = async_build(".\\build_shaders.bat", "^%.%./%.%./src/", "Shaders"),
          ["]q"] = { "<cmd>cnext<CR>", desc = "Next build issue" },
          ["[q"] = { "<cmd>cprev<CR>", desc = "Previous build issue" },
        }
      },
      autocmds = {
        cpp_auto_build = {
          {
            event = "BufWritePost",
            pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
            callback = auto_build("<F8>")
          },
          {
            event = "BufWritePost",
            pattern = { "*.vert", "*.frag", "*.glsl" },
            callback = auto_build("<F9>")
          }
        }
      }
    }
  }
}
