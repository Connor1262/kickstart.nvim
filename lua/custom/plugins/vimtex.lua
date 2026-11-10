local gh = function(repo) return 'https://github.com/' .. repo end

-- LaTeX editing, compilation (latexmk), and PDF viewing. VimTeX must not be
-- lazy-loaded, and its options have to be set before the plugin loads, so the
-- globals below come first. Mappings live under <localleader>l (<space>l here):
-- ll = toggle continuous compile, lv = view, lc = clean, le = errors, lt = TOC.
vim.g.tex_flavor = 'latex'

-- Skim gives proper forward/inverse SyncTeX search on macOS; fall back to the
-- system default PDF viewer (`open`) when it isn't installed.
if vim.fn.isdirectory '/Applications/Skim.app' == 1 then
  vim.g.vimtex_view_method = 'skim'
  vim.g.vimtex_view_skim_sync = 1
  vim.g.vimtex_view_skim_activate = 1
else
  vim.g.vimtex_view_method = 'general'
end

-- Don't pop the quickfix window open for warnings alone, only errors.
vim.g.vimtex_quickfix_open_on_warning = 0

vim.pack.add { gh 'lervag/vimtex' }
