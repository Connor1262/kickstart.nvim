local gh = function(repo) return 'https://github.com/' .. repo end

-- Arduino build/upload/serial workflow on top of arduino-cli.
-- LSP (autocomplete/diagnostics) for .ino lives in init.lua's `servers` table;
-- this file is just the compile/flash/monitor commands. By the same author as
-- conform/aerial used elsewhere in this config.
vim.pack.add { gh 'stevearc/vim-arduino' }

-- Make arduino-cli reachable inside nvim even when launched without the
-- Homebrew path (e.g. from a GUI), so :Arduino* and the LSP both find it.
if not vim.env.PATH:find('/opt/homebrew/bin', 1, true) then vim.env.PATH = '/opt/homebrew/bin:' .. vim.env.PATH end

-- vim-arduino uses arduino-cli when this is set (avoids the legacy IDE).
vim.g.arduino_use_cli = 1

-- Keymaps only attach in arduino buffers so they don't shadow anything globally.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'arduino',
  callback = function(args)
    -- vim-arduino defines its :Arduino* commands with -buffer from plugin/,
    -- so they only exist in the buffer that was current at startup. Re-source
    -- the definitions here to get them in every arduino buffer.
    vim.api.nvim_buf_call(args.buf, function() vim.cmd 'runtime! plugin/arduino.vim' end)
    local map = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { buffer = args.buf, desc = desc }) end
    -- Write first: arduino-cli compiles what's on disk, not the buffer.
    map('<leader>av', '<cmd>write<cr><cmd>ArduinoVerify<cr>', 'Arduino [V]erify (write + compile)')
    map('<leader>au', '<cmd>ArduinoUpload<cr>', 'Arduino [U]pload')
    map('<leader>as', '<cmd>ArduinoSerial<cr>', 'Arduino [S]erial monitor')
    map('<leader>am', '<cmd>ArduinoUploadAndSerial<cr>', 'Arduino upload + [M]onitor')
    map('<leader>ab', '<cmd>ArduinoChooseBoard<cr>', 'Arduino choose [B]oard')
    map('<leader>ap', '<cmd>ArduinoChoosePort<cr>', 'Arduino choose [P]ort')
    map('<leader>ai', '<cmd>ArduinoInfo<cr>', 'Arduino [I]nfo')
  end,
})
