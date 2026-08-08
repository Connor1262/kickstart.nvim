local gh = function(repo) return 'https://github.com/' .. repo end

-- Trouble: better diagnostics list
vim.pack.add { gh 'folke/trouble.nvim' }
require('trouble').setup {}

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',        { desc = 'Trouble: workspace diagnostics' })
vim.keymap.set('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Trouble: buffer diagnostics' })
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle<cr>',            { desc = 'Trouble: symbols' })

-- Diagnostic visibility toggles
local errors_only = false
vim.keymap.set('n', '<leader>te', function()
  errors_only = not errors_only
  local filter = errors_only and { severity = { min = vim.diagnostic.severity.ERROR } } or nil
  vim.diagnostic.config {
    virtual_text = filter or true,
    signs = filter or true,
    underline = filter or { severity = { min = vim.diagnostic.severity.WARN } },
  }
  vim.notify('Diagnostics: ' .. (errors_only and 'errors only' or 'all severities'))
end, { desc = '[T]oggle [E]rrors-only (hide warnings)' })

vim.keymap.set('n', '<leader>td', function()
  local on = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not on)
  vim.notify('Diagnostics ' .. (on and 'off' or 'on'))
end, { desc = '[T]oggle [D]iagnostics entirely' })

-- vim-illuminate: highlight other uses of word under cursor
vim.pack.add { gh 'RRethy/vim-illuminate' }
require('illuminate').configure {
  delay = 100,
  under_cursor = true,
}
