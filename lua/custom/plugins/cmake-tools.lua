return {
  'Civitasv/cmake-tools.nvim',
  ft = { 'c', 'cpp', 'cmake' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
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
  },
  keys = {
    { '<leader>cg', '<cmd>CMakeGenerate<cr>', desc = 'CMake [G]enerate' },
    { '<leader>cb', '<cmd>CMakeBuild<cr>', desc = 'CMake [B]uild' },
    { '<leader>cr', '<cmd>CMakeRun<cr>', desc = 'CMake [R]un' },
    { '<leader>cd', '<cmd>CMakeDebug<cr>', desc = 'CMake [D]ebug' },
    { '<leader>ct', '<cmd>CMakeSelectBuildTarget<cr>', desc = 'CMake select [T]arget' },
    { '<leader>cc', '<cmd>CMakeClean<cr>', desc = 'CMake [C]lean' },
    { '<leader>co', '<cmd>CMakeOpenRunner<cr>', desc = 'CMake [O]pen Runner' },
    { '<leader>cx', '<cmd>CMakeCloseRunner<cr>', desc = 'CMake [x]Close Runner' },
  },
}
