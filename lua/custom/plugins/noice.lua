local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'folke/noice.nvim',
  gh 'rcarriga/nvim-notify',
  gh 'MunifTanjim/nui.nvim',
}

require('notify').setup {
  render           = 'compact',
  timeout          = 2500,
  max_width        = 60,
  background_colour = '#1d2021',
}

require('noice').setup {
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
    },
    progress = { enabled = true },
    hover    = { enabled = true },
    signature = { enabled = true },
  },
  presets = {
    bottom_search        = true,
    command_palette      = true,
    long_message_to_split = true,
    lsp_doc_border       = true,
  },
  routes = {
    -- Skip DAP messages that cause stack overflow in nui's renderer
    { filter = { event = 'msg_show', find = 'DAP' },       opts = { skip = true } },
    { filter = { event = 'msg_show', find = 'codelldb' },  opts = { skip = true } },
    -- Skip very long messages that can also cause overflow
    { filter = { event = 'msg_show', min_length = 1000 },  opts = { skip = true } },
  },
}

vim.keymap.set('n', '<leader>nd', '<cmd>NoiceDismiss<CR>', { desc = '[N]oice [D]ismiss notifications' })
vim.keymap.set('n', '<leader>nh', '<cmd>Noice history<CR>', { desc = '[N]oice message [H]istory' })
vim.keymap.set('n', '<leader>nl', '<cmd>Noice last<CR>',    { desc = '[N]oice [L]ast message' })
vim.keymap.set('n', '<leader>ne', '<cmd>Noice errors<CR>',  { desc = '[N]oice [E]rrors only' })
