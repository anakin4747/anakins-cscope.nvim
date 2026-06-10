
local cs = require("anakins-cscope")

cs.cwd = 'tests/fixtures/default/'

local function logs_and_it(text, fn)
    cs.logfile = "tests/logs/" .. string.gsub(text, "[%s/]", "-") .. ".log"
    cs.should_log = true
    it(text, fn)
end

describe("anakins-cscope.goto_definition", function()
    it("can be called without errors", function()
        assert.has_no.errors(function()
            cs.goto_definition()
        end)
    end)

    it("accepts a symbol as an argument", function()
        assert.has_no.errors(function()
            cs.goto_definition('regmap_reg_range')
        end)
    end)

    logs_and_it("opens include/linux/regmap.h when passed regmap_reg_range", function()
        cs.goto_definition('regmap_reg_range')
        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)
    end)

    it("goes to include/linux/regmap.h:234 when passed regmap_reg_range", function()
        cs.goto_definition('regmap_reg_range')
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(234, row, "wrong row")
        assert.equal(9, col, "wrong column")
    end)
end)
