local gh = function(repo) return 'https://github.com/' .. repo end

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
  cmake_console_size = 10,
  cmake_show_console = 'always',
}

vim.keymap.set('n', '<leader>cg', '<cmd>CMakeGenerate<cr>', { desc = 'CMake [G]enerate' })
vim.keymap.set('n', '<leader>cb', '<cmd>CMakeBuild<cr>', { desc = 'CMake [B]uild' })
vim.keymap.set('n', '<leader>cr', '<cmd>CMakeRun<cr>', { desc = 'CMake [R]un' })
vim.keymap.set('n', '<leader>cd', '<cmd>CMakeDebug<cr>', { desc = 'CMake [D]ebug' })
vim.keymap.set('n', '<leader>ct', '<cmd>CMakeSelectBuildTarget<cr>', { desc = 'CMake select [T]arget' })
vim.keymap.set('n', '<leader>cc', '<cmd>CMakeClean<cr>', { desc = 'CMake [C]lean' })
vim.keymap.set('n', '<leader>co', '<cmd>CMakeOpenRunner<cr>', { desc = 'CMake [O]pen Runner' })
vim.keymap.set('n', '<leader>cx', '<cmd>CMakeCloseRunner<cr>', { desc = 'CMake [x]Close Runner' })
