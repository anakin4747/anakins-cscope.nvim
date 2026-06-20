vim.opt.runtimepath:append('.')
vim.opt.swapfile = false
local ac = require('anakins-cscope')

vim.cmd('cd ./tests/fixtures/default/')

ac.should_log = true
ac.logfile = 'anakins-cscope.log'

vim.g.mapleader = ' '

vim.keymap.set({ 'n', 'v' }, '<leader>ic', ac.goto_incoming_calls)
vim.keymap.set({ 'n', 'v' }, '<leader>oc', ac.goto_outgoing_calls)
vim.keymap.set({ 'n', 'v' }, 'gd', ac.goto_definition)
vim.keymap.set({ 'n', 'v' }, 'grn', ac.references)

vim.keymap.set('n', '<leader>m', function()
    vim.cmd('redir! > ../../dev/messages.log')
    vim.cmd('messages')
    vim.cmd('redir END')
end)
