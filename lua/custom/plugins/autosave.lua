-- ── Auto-save ─────────────────────────────────────────────────
-- Writes buffers to disk automatically, which is what makes running with
-- `swapfile = false` (see init.lua) safe. Saves immediately on leaving a
-- buffer or losing focus, and ~1s after you stop typing.
local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'okuuva/auto-save.nvim' }

require('auto-save').setup {
  -- Only real files: skip neo-tree, yazi, terminals, quickfix, prompts, etc.
  condition = function(buf) return vim.bo[buf].buftype == '' and vim.bo[buf].modifiable end,
}

vim.keymap.set('n', '<leader>ta', '<cmd>ASToggle<cr>', { desc = '[T]oggle [A]uto-save' })
