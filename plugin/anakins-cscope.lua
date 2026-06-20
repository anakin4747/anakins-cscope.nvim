vim.api.nvim_create_user_command('CscopeLogToggle', function()
    require('anakins-cscope').toggle_logging()
end, {})
