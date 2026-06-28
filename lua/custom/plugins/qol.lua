local gh = function(repo) return 'https://github.com/' .. repo end

-- undotree: visual undo history graph
vim.pack.add { gh 'mbbill/undotree' }
vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<cr>', { desc = '[U]ndotree toggle' })

-- persistence.nvim: save/restore sessions per directory
vim.pack.add { gh 'folke/persistence.nvim' }
require('persistence').setup {}
vim.keymap.set('n', '<leader>qs', function() require('persistence').load() end,              { desc = '[Q]uick restore [S]ession' })
vim.keymap.set('n', '<leader>ql', function() require('persistence').load { last = true } end, { desc = '[Q]uick restore [L]ast session' })
vim.keymap.set('n', '<leader>qd', function() require('persistence').stop() end,              { desc = '[Q]uick [D]ont save session' })

-- grug-far: project-wide find and replace with live preview
vim.pack.add { gh 'MagicDuck/grug-far.nvim' }
require('grug-far').setup {}
vim.keymap.set('n', '<leader>sR', function() require('grug-far').open() end,                                                    { desc = '[S]earch and [R]eplace (grug-far)' })
vim.keymap.set('n', '<leader>sW', function() require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } } end,  { desc = '[S]earch [W]ord replace (grug-far)' })

-- render-markdown: render markdown headers/bold/lists inline
vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }
require('render-markdown').setup {}
