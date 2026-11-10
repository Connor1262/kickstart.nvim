-- Float windows for programs launched from nvim.
--
-- AeroSpace's own `on-window-detected` rules can only match app-id, app-name or
-- window-title — there is no "what process launched this" criterion. So the
-- parent-process half is done here: nvim knows the pid it spawned, and
-- `aerospace list-windows --pid` turns that pid into a window id to float.

local M = {}

local AEROSPACE = vim.fn.executable 'aerospace' == 1 and 'aerospace' or '/opt/homebrew/bin/aerospace'
local POLL_MS = 150
local TIMEOUT_MS = 5000

-- Float every window owned by `pid`. A GUI window is created well after exec
-- returns, so this polls rather than checking once — a single immediate lookup
-- always finds nothing.
function M.float_pid(pid, waited)
  waited = waited or 0
  vim.system(
    { AEROSPACE, 'list-windows', '--pid', tostring(pid), '--format', '%{window-id}' },
    { text = true },
    vim.schedule_wrap(function(res)
      local found = false
      for id in (res.stdout or ''):gmatch '%d+' do
        found = true
        vim.system { AEROSPACE, 'layout', 'floating', '--window-id', id }
      end
      if not found and waited < TIMEOUT_MS then
        vim.defer_fn(function() M.float_pid(pid, waited + POLL_MS) end, POLL_MS)
      end
    end)
  )
end

-- Launch `cmd` (a list) detached, so it outlives nvim, and float it when its
-- window appears.
function M.launch(cmd)
  local job = vim.fn.jobstart(cmd, { detach = true })
  if job <= 0 then
    vim.notify('Failed to launch: ' .. table.concat(cmd, ' '), vim.log.levels.ERROR)
    return
  end
  M.float_pid(vim.fn.jobpid(job))
end

-- :Float ./build/OpenGLRepeat
vim.api.nvim_create_user_command('Float', function(opts)
  M.launch(vim.split(opts.args, ' ', { trimempty = true }))
end, { nargs = '+', complete = 'shellcmd', desc = 'Launch a program and float its AeroSpace window' })

return M
