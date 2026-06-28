local gh = function(repo) return 'https://github.com/' .. repo end

-- Trouble: better diagnostics list
vim.pack.add { gh 'folke/trouble.nvim' }
require('trouble').setup {}

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',        { desc = 'Trouble: workspace diagnostics' })
vim.keymap.set('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Trouble: buffer diagnostics' })
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle<cr>',            { desc = 'Trouble: symbols' })

-- vim-illuminate: highlight other uses of word under cursor
vim.pack.add { gh 'RRethy/vim-illuminate' }
require('illuminate').configure {
  delay = 100,
  under_cursor = true,
}
