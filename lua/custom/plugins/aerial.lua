local gh = function(repo) return 'https://github.com/' .. repo end

-- aerial: code outline / symbol tree with LSP + treesitter
vim.pack.add { gh 'stevearc/aerial.nvim' }
require('aerial').setup {
  backends = { 'lsp', 'treesitter', 'markdown', 'asciidoc', 'man' },
  show_guides = true,
  layout = { max_width = { 40, 0.2 }, min_width = 24 },
  attach_mode = 'window',
  on_attach = function(bufnr)
    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr, desc = 'Aerial prev symbol' })
    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr, desc = 'Aerial next symbol' })
  end,
}
vim.keymap.set('n', '<leader>ao', '<cmd>AerialToggle!<CR>', { desc = '[A]erial [O]utline toggle' })
vim.keymap.set('n', '<leader>af', '<cmd>AerialNavToggle<CR>', { desc = '[A]erial [F]loat nav' })
