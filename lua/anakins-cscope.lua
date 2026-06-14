
local fields = {
    symbol = "0",
    definition = "1",
    outgoing_calls = "2",
    incoming_calls = "3",
    text = "4",
    rename = "5",
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

M.parse_results = function(stdout)
    if not stdout or stdout == "" then return {} end
    local results = {}
    for line in stdout:gmatch("[^\r\n]+") do
        log_var("line", line)

        local filepath, _, row, content =
            string.match(line, "(%S+) (%S+) (%S+) (.*)")

        log_var("filepath", filepath)
        log_var("row", tonumber(row))
        log_var("content", content)

        if not (filepath and row and content) then
            goto continue
        end

        local column = string.find(content, M.symbol)

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
    vim.cmd.edit(M.cwd .. result.filepath)
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
                return {
                    value = entry,
                    display = entry.filepath .. ":" .. entry.row .. ": " .. (entry.content or ""),
                    ordinal = entry.filepath .. ":" .. entry.row,
                    filename = M.cwd .. entry.filepath,
                    lnum = entry.row,
                    col = entry.column
                }
            end,
        }),
    }):find()
end

local function jump_or_list_cscope(field, symbol)
    M.symbol = symbol or vim.fn.expand("<cword>")
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

M.should_log = true
M.cwd = "./tests/fixtures/default/"
M.goto_definition("setup_arch")

return M
