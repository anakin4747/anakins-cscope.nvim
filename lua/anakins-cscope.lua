
local fields = {
    references = "0",
    definition = "1",
    outgoing_calls = "2",
    incoming_calls = "3",
    text = "4",
    rename = "0",
    egrep = "6",
    file = "7",
    including_files = "8",
}

local M = {}

M.cwd = nil
M.symbol = nil

M.logfile = "anakins-cscope.nvim.log"
M.should_log = false

local function log(message)
    if not M.should_log then return end
    vim.fn.writefile({ message .. '\n' }, M.logfile, "a")
end

local function log_var(name, var)
    if not M.should_log then return end
    log(name .. ": '" .. vim.inspect(var) .. "'")
end

M.toggle_logging = function()
    M.should_log = not M.should_log
    if M.should_log then
        vim.cmd('redir! >> ' .. M.logfile)
        vim.api.nvim_echo({ { 'Cscope logging enabled to ' .. M.logfile, 'None' } }, false, {})
    else
        pcall(vim.cmd, 'redir END')
        vim.api.nvim_echo({ { 'Cscope logging disabled', 'None' } }, false, {})
    end
end

M.parse_results = function(stdout)
    if not stdout or stdout == "" then return {} end
    local results = {}
    for line in stdout:gmatch("[^\r\n]+") do
        log_var("line", line)

        local filepath, called_symbol, row, content =
            string.match(line, "(%S+) (%S+) (%S+) (.*)")

        log_var("filepath", filepath)
        log_var("row", tonumber(row))
        log_var("content", content)

        if not (filepath and row and content) then
            goto continue
        end

        local column = string.find(content, vim.pesc(M.symbol))

        if not column then
            column = string.find(content, vim.pesc(called_symbol))
        end

        log_var("column", column)

        if not column then
            goto continue
        end

        table.insert(results, {
            filepath = filepath,
            row = tonumber(row),
            column = column,
            content = content,
        })
        ::continue::
    end
    return results
end

local function jump_to_result(result)
    local cwd = M.cwd or vim.fn.getcwd()
    vim.cmd.edit(cwd .. "/" .. result.filepath)
    vim.api.nvim_win_set_cursor(0, { result.row, result.column })
end

local function show_telescope_picker(results)
    local pickers = require("telescope.pickers")
    local previewers = require("telescope.previewers")
    local finders = require("telescope.finders")

    pickers.new({}, {
        prompt_title = M.symbol,
        previewer = previewers.vim_buffer_qflist.new({}),
        finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
                local cwd = M.cwd or vim.fn.getcwd()
                return {
                    value = entry,
                    display = entry.filepath .. ":" .. entry.row .. ": " .. (entry.content or ""),
                    ordinal = entry.filepath .. ":" .. entry.row,
                    filename = cwd .. "/" .. entry.filepath,
                    lnum = entry.row,
                    col = entry.column
                }
            end,
        }),
    }):find()
end

local function get_visual_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local srow, scol = start_pos[2], start_pos[3]
    local erow, ecol = end_pos[2], end_pos[3]
    if srow == 0 or erow == 0 then return nil end

    if srow == erow then
        return string.sub(vim.fn.getline(srow), scol, ecol)
    end
    local lines = vim.fn.getline(srow, erow)
    lines[1] = string.sub(lines[1], scol)
    lines[#lines] = string.sub(lines[#lines], 1, ecol)
    return table.concat(lines, "\n")
end

local function jump_or_list_cscope(field, symbol)
    if not symbol then
        symbol = get_visual_selection() or vim.fn.expand("<cword>")
    end
    pcall(vim.api.nvim_buf_del_mark, 0, '<')
    pcall(vim.api.nvim_buf_del_mark, 0, '>')
    M.symbol = symbol
    local opts = { text = true, cwd = M.cwd }

    local cmd = { "cscope", "-d", "-L", "-" .. field, M.symbol }

    vim.system(cmd, opts, function(result)
        vim.schedule(function()
            log_var("cmd", cmd)
            log_var("opts", opts)
            log_var("result", result)
            log_var("symbol", M.symbol)

            local results = M.parse_results(result.stdout)
            if #results == 0 then return end

            if #results == 1 then
                jump_to_result(results[1])
            else
                show_telescope_picker(results)
            end
        end)
    end)
end

M.goto_definition = function(symbol)
    jump_or_list_cscope(fields.definition, symbol)
end

M.goto_incoming_calls = function(symbol)
    jump_or_list_cscope(fields.incoming_calls, symbol)
end

M.goto_outgoing_calls = function(symbol)
    jump_or_list_cscope(fields.outgoing_calls, symbol)
end

M.references = function(symbol)
    jump_or_list_cscope(fields.references, symbol)
end

return M
