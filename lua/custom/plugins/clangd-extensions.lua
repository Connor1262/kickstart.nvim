local gh = function(repo) return 'https://github.com/' .. repo end

-- clangd_extensions: clangd-specific extras (AST view, type hierarchy, symbol
-- info, memory usage). Inlay hints are left to Neovim's native ones (toggled
-- with <leader>th in the LSP attach config), so we disable this plugin's inline ones.
vim.pack.add { gh 'p00f/clangd_extensions.nvim' }
require('clangd_extensions').setup {
  inlay_hints = {
    inline = false, -- use native vim.lsp.inlay_hint instead
  },
}

-- Commands query the attached clangd client; bind them only in C/C++ buffers.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  callback = function(ev)
    local map = function(keys, cmd, desc)
      vim.keymap.set('n', keys, '<cmd>' .. cmd .. '<cr>', { buffer = ev.buf, desc = desc })
    end
    map('<leader>ca', 'ClangdAST', 'Clangd [A]ST')
    map('<leader>cy', 'ClangdTypeHierarchy', 'Clangd Type Hierarch[y]')
    map('<leader>ci', 'ClangdSymbolInfo', 'Clangd Symbol [I]nfo')
  end,
})
