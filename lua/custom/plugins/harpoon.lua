local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'ThePrimeagen/harpoon', version = 'harpoon2' },
  gh 'nvim-lua/plenary.nvim',
}

local harpoon = require('harpoon')
harpoon:setup()

vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end,                          { desc = '[H]arpoon [A]dd file' })
vim.keymap.set('n', '<leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,  { desc = '[H]arpoon menu' })
vim.keymap.set('n', '<leader>h1', function() harpoon:list():select(1) end,                      { desc = '[H]arpoon file [1]' })
vim.keymap.set('n', '<leader>h2', function() harpoon:list():select(2) end,                      { desc = '[H]arpoon file [2]' })
vim.keymap.set('n', '<leader>h3', function() harpoon:list():select(3) end,                      { desc = '[H]arpoon file [3]' })
vim.keymap.set('n', '<leader>h4', function() harpoon:list():select(4) end,                      { desc = '[H]arpoon file [4]' })
