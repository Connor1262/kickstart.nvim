local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'windwp/nvim-autopairs' }
require('nvim-autopairs').setup {
  check_ts = true,
  fast_wrap = {},
}
