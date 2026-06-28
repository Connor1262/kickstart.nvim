local gh = function(repo) return 'https://github.com/' .. repo end

-- treesitter-context: sticky header showing the enclosing function / class /
-- namespace at the top of the window while you scroll. Great in long C++ files.
vim.pack.add { gh 'nvim-treesitter/nvim-treesitter-context' }
require('treesitter-context').setup {
  max_lines = 3, -- how many context lines to show at most
  multiline_threshold = 1, -- collapse multiline signatures to a single line
  separator = nil, -- set to e.g. '─' for an underline beneath the context
}

-- Jump up to the context line that's currently pinned (e.g. the function header).
vim.keymap.set('n', '[x', function() require('treesitter-context').go_to_context(vim.v.count1) end, { desc = 'Jump to conte[x]t' })
