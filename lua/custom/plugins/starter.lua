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

-- Collect top-level project roots under ~/Code: any dir containing a
-- CMakeLists.txt or .git, with nested sub-projects folded into their parent.
local function project_roots()
  local base = vim.fn.expand('~/Code')
  if vim.fn.executable('fd') ~= 1 then return {} end

  local roots, seen = {}, {}
  local function collect(args)
    for _, marker in ipairs(vim.fn.systemlist(args)) do
      local dir = vim.fn.fnamemodify(marker, ':h')
      if not seen[dir] then
        seen[dir] = true
        table.insert(roots, dir)
      end
    end
  end
  collect { 'fd', '--type', 'f', '--max-depth', '6', '--glob', 'CMakeLists.txt', base }
  collect { 'fd', '--hidden', '--no-ignore', '--type', 'd', '--max-depth', '6', '--glob', '.git', base }

  table.sort(roots) -- parents sort before their children
  local top = {}
  for _, r in ipairs(roots) do
    local nested = false
    for _, t in ipairs(top) do
      if r:sub(1, #t + 1) == t .. '/' then nested = true break end
    end
    if not nested then table.insert(top, r) end
  end
  return top
end

-- Telescope picker over project roots: select one to cd in and find files.
local function pick_project()
  local roots = project_roots()
  if #roots == 0 then
    vim.notify('No projects found under ~/Code (is fd installed?)', vim.log.levels.WARN)
    return
  end

  local pickers       = require('telescope.pickers')
  local finders       = require('telescope.finders')
  local conf          = require('telescope.config').values
  local actions       = require('telescope.actions')
  local action_state  = require('telescope.actions.state')
  local home          = vim.fn.expand('~')

  pickers.new({}, {
    prompt_title = 'Projects',
    finder = finders.new_table {
      results = roots,
      entry_maker = function(path)
        local display = path:gsub('^' .. vim.pesc(home), '~')
        return { value = path, display = display, ordinal = display }
      end,
    },
    sorter = conf.generic_sorter {},
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(bufnr)
        if entry then
          vim.cmd.cd(vim.fn.fnameescape(entry.value))
          require('telescope.builtin').find_files()
        end
      end)
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>sp', pick_project, { desc = '[S]earch [P]rojects' })

starter.setup {
  header = side_by_side(frog, neovim_text),
  items = {
    { name = 'Projects',              action = pick_project,                                        section = '' },
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
