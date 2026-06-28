local gh = function(repo) return 'https://github.com/' .. repo end

-- indent-blankline: visual indent guides
vim.pack.add { gh 'lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {
  indent = { char = '│' },
  scope = { enabled = true },
}

-- nvim-colorizer: highlight colour codes inline
vim.pack.add { gh 'norcalli/nvim-colorizer.lua' }
require('colorizer').setup(
  { 'css', 'html', 'javascript', 'typescript', 'lua', 'glsl' },
  { RGB = true, RRGGBB = true, names = true, css = true }
)
