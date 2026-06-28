local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'rcarriga/nvim-dap-ui',
  gh 'nvim-neotest/nvim-nio',
  gh 'theHamsta/nvim-dap-virtual-text',
  gh 'jay-babu/mason-nvim-dap.nvim',
}

local dap = require('dap')
local dapui = require('dapui')

require('mason-nvim-dap').setup {
  automatic_installation = true,
  ensure_installed = { 'codelldb' },
  handlers = {},
}

dapui.setup()
require('nvim-dap-virtual-text').setup()

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
    args = { '--port', '${port}' },
  },
}

dap.configurations.cpp = {
  {
    name = 'Launch (integrated terminal)',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    terminal = 'integrated',
  },
  {
    name = 'Launch (no terminal / no stdin)',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
    end,
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
vim.keymap.set('n', '<leader>du', function() dapui.toggle() end, { desc = 'Debug: Toggle [U]I' })
vim.keymap.set('n', '<leader>dt', function() dap.terminate() end, { desc = 'Debug: [T]erminate' })
