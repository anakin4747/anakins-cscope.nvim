
local cs = require("anakins-cscope")

cs.cwd = 'tests/fixtures/default/'

local function _it(text, fn)
    cs.logfile = "tests/logs/" .. string.gsub(text, "[%s/:]", "-") .. ".log"
    cs.should_log = true
    it(text, fn)
end

describe("anakins-cscope.goto_definition", function()
    _it("can be called without errors", function()
        assert.has_no.errors(function()
            cs.goto_definition()
        end)
    end)

    _it("accepts a symbol as an argument", function()
        assert.has_no.errors(function()
            cs.goto_definition('regmap_reg_range')
        end)
    end)

    _it("opens include/linux/regmap.h when passed regmap_reg_range", function()
        cs.goto_definition('regmap_reg_range')
        vim.wait(100)
        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)
    end)

    _it("goes to include/linux/regmap.h:234 when passed regmap_reg_range", function()
        cs.goto_definition('regmap_reg_range')
        vim.wait(100)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(234, row, "wrong row")
        assert.equal(8, col, "wrong column")
    end)

    _it("opens include/linux/regmap.h when cursor on regmap_reg_range", function()
        vim.cmd.edit(cs.cwd .. "drivers/pmdomain/imx/gpc.c")
        vim.api.nvim_win_set_cursor(0, { 328, 3 })
        cs.goto_definition()
        vim.wait(100)
        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)
    end)

    _it("goes to include/linux/regmap.h:234 when cursor on regmap_reg_range", function()
        vim.cmd.edit(cs.cwd .. "drivers/pmdomain/imx/gpc.c")
        vim.api.nvim_win_set_cursor(0, { 328, 3 })
        cs.goto_definition()
        vim.wait(100)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(234, row, "wrong row")
        assert.equal(8, col, "wrong column")
    end)

    -- _it("cancels the previous vim.system command if called again", function()
    --
    -- end)
end)
