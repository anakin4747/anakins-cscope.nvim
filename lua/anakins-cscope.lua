
local M = {}

---@type vim.SystemObj
M.systemobj = nil
M.cwd = nil

-- Find this C symbol:              <-- Field 0
-- Find this global definition:     <-- Field 1
-- Find functions called by this:   <-- Field 2
-- Find functions calling this:     <-- Field 3
-- Find this text string:           <-- Field 4
-- Change this text string:         <-- Field 5
-- Find this egrep pattern:         <-- Field 6
-- Find this file:                  <-- Field 7
-- Find files #including this file: <-- Field 8

M.logfile = "anakins-cscope.nvim.log"
M.should_log = true

M.log = function(message)
    if not M.should_log then return end

    vim.fn.writefile(message .. '\n', M.logfile, "a")
end

M.goto_definition = function(symbol)
    local opts = { text = true, cwd = M.cwd }

    local cmd = { "cscope", "-d", "-L", "-1", symbol }

    vim.system(cmd, opts, function(result)
        vim.schedule(function()
            M.log("cmd: '" .. vim.inspect(cmd) .. "'")
            M.log("opts: '" .. vim.inspect(opts) .. "'")
            M.log("stdout: '" .. result.stdout .. "'")
            M.log("symbol: '" .. symbol .. "'")
            local filepath, _, row, content =
                string.match(result.stdout, "(%S+) (%S+) (%S+) (.*)")
            M.log("filepath: '" .. vim.inspect(filepath) .. "'")
            M.log("row: '" .. row .. "'")
            M.log("content: '" .. content .. "'")

            vim.cmd.edit(M.cwd .. filepath)

            local column = string.find(content, symbol)

            M.log("column: '" .. column .. "'")

            vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(column) })
        end)
    end)
end

-- cscope {{{
    -- TODO: investigate if gtags-cscope cli is better

--      -b     Build the cross-reference only.
--      -q     Inverted index for quick lookup
--      -k     Kernel mode
--      -v     verbose

-- cscope -f file -bqkv

-- local function cscope_goto_def(symbol)
--     -- -d Do not update the cross-reference.
--     -- -L Do a single search with line-oriented output when used with the -num pattern option.
--     -- -[0-9]pattern Go to input field num (counting from 0) and find pattern.
--         -- -1 Find this global definition:
--
--     local cmd = "cscope -d -L -1 " .. symbol
--
--     vim.system(cmd, { text = true }, function(result)
--         vim.schedule(function()
--             local split = vim.fn.split(result)
--         end)
--     end)
--
-- end

return M
