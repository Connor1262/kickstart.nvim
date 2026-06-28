local gh = function(repo) return 'https://github.com/' .. repo end

-- flash.nvim: jump anywhere on screen in 2-3 keystrokes
vim.pack.add { gh 'folke/flash.nvim' }
require('flash').setup {}

vim.keymap.set({ 'n', 'x', 'o' }, 's',  function() require('flash').jump() end,       { desc = 'Flash jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S',  function() require('flash').treesitter() end, { desc = 'Flash treesitter jump' })
vim.keymap.set('o',               'r',  function() require('flash').remote() end,      { desc = 'Flash remote (operator)' })

-- neoscroll: smooth Ctrl+d/u/f/b scrolling
vim.pack.add { gh 'karb94/neoscroll.nvim' }
require('neoscroll').setup { duration_multiplier = 0.6 }
