-- ── Yazi ──────────────────────────────────────────────────────
-- Opens yazi in a floating window inside nvim. Picking a file opens it as a
-- buffer, and renames/moves/deletes made in yazi are synced back to any open
-- buffers. Ghostty speaks the Kitty graphics protocol, so image, video and
-- PDF previews render inside the float rather than falling back to ASCII.
local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'mikavilpas/yazi.nvim' },
  gh 'nvim-lua/plenary.nvim', -- also added by neotree.lua; add is idempotent
}

require('yazi').setup {
  -- neo-tree hijacks directory buffers by default, so this stays off to keep
  -- `nvim somedir/` opening neo-tree rather than the two fighting over it.
  open_for_directories = false,
  keymaps = { show_help = '<f1>' },
}

-- `\` stays neo-tree, the persistent project sidebar. These are the full
-- file manager: bulk select, move, rename, media preview.
vim.keymap.set({ 'n', 'v' }, '<leader>-', '<cmd>Yazi<cr>', { desc = 'Yazi at current file' })
vim.keymap.set('n', '<leader>_', '<cmd>Yazi cwd<cr>', { desc = 'Yazi in working directory' })
