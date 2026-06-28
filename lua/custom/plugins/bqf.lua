local gh = function(repo) return 'https://github.com/' .. repo end

-- nvim-bqf: better quickfix window — inline preview + fuzzy filtering. Pairs
-- with cmake-tools' `quickfix` build executor for navigating build errors.
-- Auto-attaches to quickfix windows (filetype=qf); no keymaps needed.
vim.pack.add { gh 'kevinhwang91/nvim-bqf' }
require('bqf').setup {
  auto_enable = true,
  preview = {
    auto_preview = true,
    win_height = 15,
  },
}
