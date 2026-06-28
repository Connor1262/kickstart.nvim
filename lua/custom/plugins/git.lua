local gh = function(repo) return 'https://github.com/' .. repo end

-- lazygit: floating terminal git UI
vim.pack.add {
  gh 'kdheepak/lazygit.nvim',
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
}
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'Lazy[G]it' })

-- diffview: rich git diff and history viewer
vim.pack.add { gh 'sindrets/diffview.nvim' }
require('diffview').setup {}
vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>',        { desc = '[G]it [D]iff view' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', { desc = '[G]it file [H]istory' })
vim.keymap.set('n', '<leader>gx', '<cmd>DiffviewClose<cr>',       { desc = '[G]it diff close' })
