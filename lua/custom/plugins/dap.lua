return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'jay-babu/mason-nvim-dap.nvim',
  },
  keys = {
    { '<F5>',       function() require('dap').continue() end,          desc = 'Debug: Start/Continue' },
    { '<F10>',      function() require('dap').step_over() end,         desc = 'Debug: Step Over' },
    { '<F11>',      function() require('dap').step_into() end,         desc = 'Debug: Step Into' },
    { '<F12>',      function() require('dap').step_out() end,          desc = 'Debug: Step Out' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle [B]reakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end, desc = 'Debug: Conditional [B]reakpoint' },
    { '<leader>dr', function() require('dap').repl.open() end,         desc = 'Debug: Open [R]EPL' },
    { '<leader>dl', function() require('dap').run_last() end,          desc = 'Debug: Run [L]ast' },
    { '<leader>du', function() require('dapui').toggle() end,          desc = 'Debug: Toggle [U]I' },
    { '<leader>dt', function() require('dap').terminate() end,         desc = 'Debug: [T]erminate' },
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    require('mason-nvim-dap').setup({
      automatic_installation = true,
      ensure_installed = { 'codelldb' },
      handlers = {},
    })

    dapui.setup()
    require('nvim-dap-virtual-text').setup()

    -- Auto-open/close the UI with the debug session
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- codelldb adapter for C/C++/Rust
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
        args = { '--port', '${port}' },
      },
    }

    -- C++ launch configuration: prompts for the binary path on each <F5>
    dap.configurations.cpp = {
      {
        name = 'Launch file',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    -- Reuse C++ config for C
    dap.configurations.c = dap.configurations.cpp
  end,
}
