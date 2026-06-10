
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

M.goto_definition = function()
    vim.system(cmd, opts, on_exit)
end

M.goto_declaration = function()

end

-- cscope {{{
    -- TODO: investigate if gtags-cscope cli is better

--      -b     Build the cross-reference only.
--      -q     Inverted index for quick lookup
--      -k     Kernel mode
--      -v     verbose

-- cscope -f file -bqkv

local function cscope_goto_def(symbol)
    -- -d Do not update the cross-reference.
    -- -L Do a single search with line-oriented output when used with the -num pattern option.
    -- -[0-9]pattern Go to input field num (counting from 0) and find pattern.
        -- -1 Find this global definition:

    local cmd = "cscope -d -L -1 " .. symbol

    vim.system(cmd, { text = true }, function(result)
        vim.schedule(function()
            local split = vim.fn.split(result)
        end)
    end)

end

return M
