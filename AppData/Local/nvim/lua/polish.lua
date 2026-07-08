-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

local remedybg_exe = "C:/Users/spoon/Downloads/remedybg_0_3_6_4/remedybg.exe"

local function in_engine()
  return vim.fn.getcwd():match("project%-wormwood%-engine") ~= nil
end

local function focus_game()
  -- Poll for the game process up to 2 seconds and bring it to the foreground
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

-- F5: Start Debugging (and launch if closed)
vim.keymap.set("n", "<F5>", function()
  if not in_engine() then return end
  
  vim.system({ "tasklist", "/FI", "IMAGENAME eq remedybg.exe" }, { text = true }, function(tasklist_obj)
    if tasklist_obj.stdout and tasklist_obj.stdout:match("remedybg%.exe") then
      vim.schedule(function()
        vim.fn.jobstart({ remedybg_exe, "start-debugging" }, { detach = true })
        focus_game()
      end)
    else
      vim.schedule(function()
        -- Launch remedy with session
        vim.fn.jobstart({ remedybg_exe, "debugger/hayden.rdbg" }, { detach = true })
        -- Wait a bit for it to open and load the session, then start debugging
        vim.defer_fn(function()
          vim.fn.jobstart({ remedybg_exe, "start-debugging" }, { detach = true })
          focus_game()
        end, 300)
      end)
    end
  end)
end, { desc = "Start Debugging in RemedyBG" })

-- Shift+F5: Stop Debugging
vim.keymap.set("n", "<S-F5>", function()
  if not in_engine() then return end
  
  vim.system({ "tasklist", "/FI", "IMAGENAME eq remedybg.exe" }, { text = true }, function(tasklist_obj)
    if tasklist_obj.stdout and tasklist_obj.stdout:match("remedybg%.exe") then
      vim.schedule(function()
        vim.fn.jobstart({ remedybg_exe, "stop-debugging" }, { detach = true })
      end)
    end
  end)
end, { desc = "Stop Debugging in RemedyBG" })

-- F6: Restart Debugging (Stop then Start)
vim.keymap.set("n", "<F6>", function()
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
end, { desc = "Restart Debugging in RemedyBG" })

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

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
  callback = auto_build("<F8>")
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.vert", "*.frag", "*.glsl" },
  callback = auto_build("<F9>")
})
