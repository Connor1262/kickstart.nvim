local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'mfussenegger/nvim-lint' }

local lint = require('lint')
lint.linters_by_ft = {
  c   = { 'cppcheck' },
  cpp = { 'cppcheck' },
}

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  callback = function()
    lint.try_lint()
  end,
})

vim.keymap.set('n', '<leader>ll', function() lint.try_lint() end, { desc = '[L]int current buffer' })
