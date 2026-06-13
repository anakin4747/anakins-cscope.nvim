
local M = {}

---@type vim.SystemObj
M.systemobj = nil
M.cwd = nil
local _symbol

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
        local filepath, _, row, content = string.match(line, "(%S+) (%S+) (%S+) (.*)")
        if filepath and row then
            table.insert(results, {
                filepath = filepath,
                row = tonumber(row),
                content = content or "",
            })
        end
    end
    return results
end

local function jump_to_result(result)
    vim.cmd.edit(M.cwd .. result.filepath)
    local column = string.find(result.content, _symbol) - 1
    vim.api.nvim_win_set_cursor(0, { result.row, column })
end

local function show_telescope_picker(results)
    require("telescope.pickers").new({}, {
        prompt_title = _symbol,
        finder = require("telescope.finders").new_table {
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.filepath .. ":" .. entry.row .. ": " .. (entry.content or ""),
                    ordinal = entry.filepath .. ":" .. entry.row,
                    filename = M.cwd .. entry.filepath,
                    lnum = entry.row,
                }
            end,
        },
    }):find()
end

M.goto_definition = function(symbol)
    _symbol = symbol or vim.fn.expand("<cword>")
    local opts = { text = true, cwd = M.cwd }

    local cmd = { "cscope", "-d", "-L", "-1", _symbol }

    vim.system(cmd, opts, function(result)
        vim.schedule(function()
            log_var("cmd", cmd)
            log_var("opts", opts)
            log_var("result", result)
            log_var("symbol", _symbol)

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

M.should_log = true
M.cwd = "./tests/fixtures/default/"
M.goto_definition("setup_arch")


-- Find this C symbol:              <-- Field 0
-- Find this global definition:     <-- Field 1
-- Find functions called by this:   <-- Field 2
-- Find functions calling this:     <-- Field 3
-- Find this text string:           <-- Field 4
-- Change this text string:         <-- Field 5
-- Find this egrep pattern:         <-- Field 6
-- Find this file:                  <-- Field 7
-- Find files #including this file: <-- Field 8

return M
