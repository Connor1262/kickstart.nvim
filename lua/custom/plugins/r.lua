local gh = function(repo) return 'https://github.com/' .. repo end

-- R editing and a REPL: R.nvim runs R in a terminal split and sends code to it.
-- Mappings live under <localleader> (<space> here): <space>rf = start R,
-- <Enter> = send line/selection, <space>rq = quit R, <space>ro = object browser.
vim.pack.add { gh 'R-nvim/R.nvim' }

require('r').setup {
  R_args = { '--quiet', '--no-save' },
  hook = {
    on_filetype = function()
      vim.keymap.set('n', '<Enter>', '<Plug>RDSendLine', { buffer = true })
      vim.keymap.set('v', '<Enter>', '<Plug>RSendSelection', { buffer = true })
    end,
  },
  min_editor_width = 72,
  rconsole_width = 78,
  pdfviewer = 'open',
}
