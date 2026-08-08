-- Native Makefile workflow: makeprg + quickfix, mirroring the cmake-tools
-- ergonomics under <leader>m. No extra plugins — builds run through `:make`
-- and land in the quickfix list, where nvim-bqf (see bqf.lua) previews them.

-- Prefer Homebrew's GNU Make (`gmake`, 4.x) over macOS's stock /usr/bin/make
-- (3.81). makeprg is what `:make` shells out to; the rest is the default.
local make_cmd = vim.fn.executable 'gmake' == 1 and 'gmake' or 'make'
vim.o.makeprg = make_cmd .. ' $*'

-- The standard names GNU Make looks for, in priority order.
local MAKEFILE_NAMES = { 'GNUmakefile', 'makefile', 'Makefile' }

-- Locate the Makefile in the current working directory (cmake-tools/this config
-- keep cwd at the project root via the global auto-cd in init.lua).
local function find_makefile()
  for _, name in ipairs(MAKEFILE_NAMES) do
    local path = vim.fs.joinpath(vim.uv.cwd(), name)
    if vim.uv.fs_stat(path) then return path end
  end
  return nil
end

-- Parse explicit targets out of a Makefile. Matches `name:` rule lines while
-- skipping variable assignments (`VAR := ...`), pattern rules (`%.o:`), and
-- special dot-targets (`.PHONY:`). Good enough for picking a target by hand.
local function makefile_targets(path)
  local targets, seen = {}, {}
  for line in io.lines(path) do
    local name = line:match '^([%w][%w%-_%.+]*)%s*:'
    -- a target line's `:` is not immediately followed by `=` (that's `:=`)
    if name and not line:match '^[%w][%w%-_%.+]*%s*:=' and not seen[name] then
      seen[name] = true
      table.insert(targets, name)
    end
  end
  return targets
end

-- Run `make <target>` through :make so errors populate the quickfix list, then
-- open the quickfix window only when there's something to look at.
local function run_make(target)
  vim.cmd('silent make' .. (target and (' ' .. target) or ''))
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd 'botright cwindow'
  else
    vim.notify('make ' .. (target or '') .. ' — done, no errors', vim.log.levels.INFO)
  end
end

vim.keymap.set('n', '<leader>mm', function() run_make() end, { desc = 'Make (default target)' })
vim.keymap.set('n', '<leader>mc', function() run_make 'clean' end, { desc = 'Make [c]lean' })

vim.keymap.set('n', '<leader>mt', function()
  local path = find_makefile()
  if not path then
    vim.notify('No Makefile found in ' .. vim.uv.cwd(), vim.log.levels.WARN)
    return
  end
  local targets = makefile_targets(path)
  if vim.tbl_isempty(targets) then
    vim.notify('No targets found in ' .. vim.fs.basename(path), vim.log.levels.WARN)
    return
  end
  vim.ui.select(targets, { prompt = 'Make target:' }, function(choice)
    if choice then run_make(choice) end
  end)
end, { desc = 'Make: pick [t]arget' })
