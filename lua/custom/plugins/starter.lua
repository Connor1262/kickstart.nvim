local starter = require('mini.starter')

local frog = [[
                       ,-.
                  _,-' - `--._
                ,'.:  __' _..-)
              ,'     /,o)'  ,'
             ;.    ,'`-' _,)
           ,'   :.   _.-','
         ,' .  .    (   /
        ; .:'     .. `-/
      ,'       ;     ,'
   _,/ .   ,      .,' ,
 ,','     .  .  . .\,'..__
,','  .:.      ' ,\ `\)``
`-\_..---``````-'-.`.:`._/
,'   '` .` ,`- -.  ) `--..`-..
`-...__________..-'-.._  \
   ``--------..`-._ ```
               ``    ]]

local neovim_text = [[
 ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
 ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]

local function side_by_side(left_art, right_art, gap)
  gap = gap or 6
  local left_lines = vim.split(left_art, '\n')
  local right_lines = vim.split(right_art, '\n')

  local left_width = 0
  for _, line in ipairs(left_lines) do
    left_width = math.max(left_width, vim.fn.strdisplaywidth(line))
  end

  local n_left, n_right = #left_lines, #right_lines
  local max_lines = math.max(n_left, n_right)
  local left_offset = math.floor((max_lines - n_left) / 2)
  local right_offset = math.floor((max_lines - n_right) / 2)

  local result = {}
  for i = 1, max_lines do
    local li, ri = i - left_offset, i - right_offset
    local left = (li >= 1 and li <= n_left) and left_lines[li] or ''
    local right = (ri >= 1 and ri <= n_right) and right_lines[ri] or ''
    local pad = left_width - vim.fn.strdisplaywidth(left) + gap
    table.insert(result, left .. string.rep(' ', pad) .. right)
  end

  return table.concat(result, '\n')
end

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'MiniStarterHeader', { fg = '#fabd2f' })
  end,
})

starter.setup {
  header = side_by_side(frog, neovim_text),
  items = {
    { name = 'Find file',             action = 'Telescope find_files',                              section = '' },
    { name = 'Edit new file',         action = 'enew',                                              section = '' },
    { name = 'Configuration',         action = 'edit ' .. vim.fn.stdpath('config') .. '/init.lua', section = '' },
    { name = 'Update plugins',        action = 'lua vim.pack.update()',                             section = '' },
    { name = 'Recently opened files', action = 'Telescope oldfiles',                                section = '' },
    { name = 'Quit',                  action = 'qa',                                                section = '' },
  },
  footer = 'The universe is all a spin-off of the Big Bang.',
  content_hooks = {
    starter.gen_hook.adding_bullet('  '),
    starter.gen_hook.aligning('center', 'center'),
  },
}
