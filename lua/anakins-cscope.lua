
local M = {}

---@type vim.SystemObj
M.systemobj = nil
M.cwd = nil
M._symbol = nil

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

M.goto_definition = function(symbol)
    M._symbol = symbol
    local opts = { text = true, cwd = M.cwd }

    local cmd = { "cscope", "-d", "-L", "-1", M._symbol }

    vim.system(cmd, opts, function(result)
        vim.schedule(function()
            log_var("cmd", cmd)
            log_var("opts", opts)
            log_var("result", result)
            log_var("M._symbol", M._symbol)

            local filepath, _, row, content =
                string.match(result.stdout, "(%S+) (%S+) (%S+) (.*)")

            if not (filepath and row and content) then return end

            log_var("filepath", filepath)
            log_var("row", row)
            log_var("content", content)

            vim.cmd.edit(M.cwd .. filepath)

            local column = string.find(content, M._symbol) - 1

            log_var("column", column)

            vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(column) })
        end)
    end)
end

M.cwd = 'tests/fixtures/default/'
M.goto_definition('regmap_reg_range')

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
