local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'igorlfs/nvim-dap-view',
  gh 'theHamsta/nvim-dap-virtual-text',
  gh 'jay-babu/mason-nvim-dap.nvim',
}

local dap = require('dap')
local dapview = require('dap-view')

require('mason-nvim-dap').setup {
  automatic_installation = true,
  ensure_installed = { 'codelldb' },
  handlers = {},
}

dapview.setup()
require('nvim-dap-virtual-text').setup()

dap.listeners.after.event_initialized['dapview_config'] = function() dapview.open() end
dap.listeners.before.event_terminated['dapview_config'] = function() dapview.close() end
dap.listeners.before.event_exited['dapview_config'] = function() dapview.close() end

dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
    args = { '--port', '${port}' },
  },
}

-- Executables under dir, skipping CMake's internal files and shared libs.
local function find_executables(dir)
  return vim.fs.find(function(name, path)
    if path:find('CMakeFiles', 1, true) or name:match('%.dylib$') or name:match('%.so[%.%d]*$') or name:match('%.sh$') then
      return false
    end
    return vim.fn.executable(path .. '/' .. name) == 1
  end, { path = dir, type = 'file', limit = math.huge })
end

-- Resolve the program to debug: the cmake-tools launch target if one is
-- selected, else the only executable in build/, else a picker over all of them.
-- Typing a directory at the prompt resolves to the single executable inside it.
local function pick_executable()
  local ok, cmake = pcall(require, 'cmake-tools')
  if ok then
    local target_path = cmake.get_launch_target_path()
    if target_path and vim.fn.executable(target_path) == 1 then
      return vim.fn.input('Path to executable: ', target_path, 'file')
    end
  end

  local build_dir = vim.fn.getcwd() .. '/build'
  local exes = find_executables(build_dir)
  if #exes > 1 then
    return coroutine.create(function(dap_run_co)
      vim.ui.select(exes, {
        prompt = 'Executable to debug:',
        format_item = function(p) return vim.fn.fnamemodify(p, ':~:.') end,
      }, function(choice) coroutine.resume(dap_run_co, choice or dap.ABORT) end)
    end)
  end

  local path = vim.fn.input('Path to executable: ', exes[1] or (build_dir .. '/'), 'file')
  if path == '' then
    return dap.ABORT
  end
  if vim.fn.isdirectory(path) == 1 then
    local inside = find_executables(path)
    if #inside ~= 1 then
      error(('"%s" has %d executables — pick one (or run :CMakeBuild first)'):format(path, #inside), 0)
    end
    path = inside[1]
  end
  return path
end

dap.configurations.cpp = {
  {
    name = 'Launch (integrated terminal)',
    type = 'codelldb',
    request = 'launch',
    program = pick_executable,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    terminal = 'integrated',
  },
  {
    name = 'Launch (no terminal / no stdin)',
    type = 'codelldb',
    request = 'launch',
    program = pick_executable,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}
dap.configurations.c = dap.configurations.cpp

vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = 'Debug: Toggle [B]reakpoint' })
vim.keymap.set('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Condition: ')) end, { desc = 'Debug: Conditional [B]reakpoint' })
vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { desc = 'Debug: Open [R]EPL' })
vim.keymap.set('n', '<leader>dl', function() dap.run_last() end, { desc = 'Debug: Run [L]ast' })
vim.keymap.set('n', '<leader>du', function() dapview.toggle() end, { desc = 'Debug: Toggle [U]I' })
vim.keymap.set('n', '<leader>dw', function() dapview.add_expr() end, { desc = 'Debug: Add [W]atch' })
vim.keymap.set('n', '<leader>dt', function() dap.terminate() end, { desc = 'Debug: [T]erminate' })
