local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = 'v3.x' },
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-tree/nvim-web-devicons',
  gh 'MunifTanjim/nui.nvim',
}

require('neo-tree').setup {
  filesystem = {
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}

vim.keymap.set('n', '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
