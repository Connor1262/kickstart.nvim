local gh = function(repo) return 'https://github.com/' .. repo end

-- General-purpose terminal (not the cmake runner; that uses cmake-tools' own).
vim.pack.add { gh 'akinsho/toggleterm.nvim' }
require('toggleterm').setup {
  open_mapping = [[<C-\>]],
  direction    = 'horizontal',
  size         = 15,
}
vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<cr>',                       { desc = '[T]oggle [T]erminal' })
vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>',    { desc = '[T]erminal [V]ertical' })
vim.keymap.set('n', '<leader>ts', '<cmd>ToggleTerm direction=horizontal<cr>',  { desc = '[T]erminal [S]plit horizontal' })

-- nvim-dap must be loaded before cmake-tools so CMakeDebug gets registered
vim.pack.add { gh 'mfussenegger/nvim-dap' }
require('dap')

vim.pack.add {
  gh 'Civitasv/cmake-tools.nvim',
  gh 'nvim-lua/plenary.nvim',
}

require('cmake-tools').setup {
  cmake_command = 'cmake',
  cmake_build_directory = 'build',
  cmake_generate_options = {
    '-DCMAKE_EXPORT_COMPILE_COMMANDS=1',
    '-G',
    'Ninja',
  },
  cmake_soft_link_compile_commands = true,
  cmake_build_options = {},
  cmake_executor = {
    name = 'quickfix',
    opts = {},
    default_opts = {
      quickfix = {
        show = 'always',
        position = 'belowright',
        size = 10,
      },
    },
  },
  cmake_runner = {
    name = 'toggleterm',
    opts = {},
    default_opts = {
      toggleterm = {
        direction = 'horizontal', -- match the general-purpose toggleterm above
        close_on_exit = false, -- keep program output visible after it exits
        auto_scroll = true,
        auto_focus = true,
        singleton = true, -- reuse one terminal, autoclosing any previous run
      },
    },
  },
}

-- NOTE: auto-cd to the project root is handled globally in init.lua
-- (cd_to_project_root + the BufEnter autocmd), which fires DirChanged and keeps
-- cmake-tools, telescope and neo-tree in sync. No per-plugin autocmd needed here.

vim.keymap.set('n', '<leader>cg', '<cmd>CMakeGenerate<cr>', { desc = 'CMake [G]enerate' })
vim.keymap.set('n', '<leader>cb', '<cmd>CMakeBuild<cr>', { desc = 'CMake [B]uild' })
vim.keymap.set('n', '<leader>cr', '<cmd>CMakeRun<cr>', { desc = 'CMake [R]un' })
vim.keymap.set('n', '<leader>cd', '<cmd>CMakeDebug<cr>', { desc = 'CMake [D]ebug' })
vim.keymap.set('n', '<leader>ct', '<cmd>CMakeSelectBuildTarget<cr>', { desc = 'CMake select [T]arget' })
vim.keymap.set('n', '<leader>cc', '<cmd>CMakeClean<cr>', { desc = 'CMake [C]lean' })
vim.keymap.set('n', '<leader>co', '<cmd>CMakeOpenRunner<cr>', { desc = 'CMake [O]pen Runner' })
vim.keymap.set('n', '<leader>cx', '<cmd>CMakeCloseRunner<cr>', { desc = 'CMake [x]Close Runner' })
vim.keymap.set('n', '<leader>cw', '<cmd>CMakeSelectCwd<cr>', { desc = 'CMake select [W]orking dir (root)' })
