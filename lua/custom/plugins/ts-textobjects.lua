local gh = function(repo) return 'https://github.com/' .. repo end

-- nvim-treesitter-textobjects: select / move / swap by syntax node (function,
-- class, parameter). MUST track the `main` branch to match nvim-treesitter main.
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter-textobjects', version = 'main' } }

require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true, -- jump forward to the textobject if the cursor is before it
  },
  move = {
    set_jumps = true, -- record moves in the jumplist (navigate with <C-o>/<C-i>)
  },
}

local select = require('nvim-treesitter-textobjects.select')
local move = require('nvim-treesitter-textobjects.move')
local swap = require('nvim-treesitter-textobjects.swap')

-- [[ Selection ]] (visual + operator-pending)
-- Note: uses `am`/`im` (m = method) for function definitions so it does NOT
-- clobber mini.ai's `af`/`if` (function *call*). `ac`/`ic` = class, `a,`/`i,` = arg.
local function sel(key, obj, desc)
  vim.keymap.set({ 'x', 'o' }, key, function() select.select_textobject(obj, 'textobjects') end, { desc = desc })
end
sel('am', '@function.outer', 'a function')
sel('im', '@function.inner', 'inner function')
sel('ac', '@class.outer', 'a class')
sel('ic', '@class.inner', 'inner class')
sel('a,', '@parameter.outer', 'a parameter')
sel('i,', '@parameter.inner', 'inner parameter')

-- [[ Movement ]] (normal + visual + operator-pending) — classic textobjects keys
local function mv(key, fn, obj, desc)
  vim.keymap.set({ 'n', 'x', 'o' }, key, function() fn(obj, 'textobjects') end, { desc = desc })
end
mv(']m', move.goto_next_start, '@function.outer', 'Next function start')
mv(']M', move.goto_next_end, '@function.outer', 'Next function end')
mv('[m', move.goto_previous_start, '@function.outer', 'Prev function start')
mv('[M', move.goto_previous_end, '@function.outer', 'Prev function end')
mv(']]', move.goto_next_start, '@class.outer', 'Next class start')
mv('][', move.goto_next_end, '@class.outer', 'Next class end')
mv('[[', move.goto_previous_start, '@class.outer', 'Prev class start')
mv('[]', move.goto_previous_end, '@class.outer', 'Prev class end')

-- [[ Swap ]] parameters left/right
vim.keymap.set('n', '<leader>a', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap parameter with next' })
vim.keymap.set('n', '<leader>A', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap parameter with previous' })
