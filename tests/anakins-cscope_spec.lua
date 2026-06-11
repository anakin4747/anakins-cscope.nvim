
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

describe("anakins-cscope.parse_results", function()
    it("returns empty list for empty stdout", function()
        local results = cs.parse_results("")
        assert.are.same({}, results)
    end)

    it("returns empty list for nil stdout", function()
        local results = cs.parse_results(nil)
        assert.are.same({}, results)
    end)

    it("parses single result from cscope stdout", function()
        local stdout = "include/linux/regmap.h regmap_reg_range 234 #define regmap_reg_range(low, high) { .range_min = low, .range_max = high, }\n"
        local results = cs.parse_results(stdout)
        assert.equal(1, #results)
        assert.equal("include/linux/regmap.h", results[1].filepath)
        assert.equal(234, results[1].row)
        assert.matches("regmap_reg_range", results[1].content)
    end)

    it("parses multiple results for setup_arch", function()
        local stdout = "arch/arm/kernel/setup.c setup_arch 1096 void __init setup_arch(char **cmdline_p)\narch/x86/kernel/setup.c setup_arch 884 void __init setup_arch(char **cmdline_p)\n"
        local results = cs.parse_results(stdout)
        assert.equal(2, #results)
        assert.equal("arch/arm/kernel/setup.c", results[1].filepath)
        assert.equal(1096, results[1].row)
        assert.equal("arch/x86/kernel/setup.c", results[2].filepath)
        assert.equal(884, results[2].row)
    end)

    it("skips lines that don't match the pattern", function()
        local stdout = "short\ninclude/linux/regmap.h regmap_reg_range 234 #define\n"
        local results = cs.parse_results(stdout)
        assert.equal(1, #results)
        assert.equal("include/linux/regmap.h", results[1].filepath)
    end)
end)

describe("anakins-cscope telescope integration", function()
    it("opens telescope picker with 2 results for setup_arch", function()
        local captured_results
        local orig_show = cs._show_telescope_picker
        cs._show_telescope_picker = function(results)
            captured_results = results
            orig_show(results)
        end

        cs.goto_definition('setup_arch')
        vim.wait(500)

        assert.is_not_nil(captured_results)
        assert.equal(2, #captured_results)
        assert.matches("arch/arm/kernel/setup.c", captured_results[1].filepath)
        assert.matches("arch/x86/kernel/setup.c", captured_results[2].filepath)

        cs._show_telescope_picker = orig_show
    end)

    it("still jumps directly for single-result symbols", function()
        cs.goto_definition('regmap_reg_range')
        vim.wait(500)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.equal(0, #prompts, "telescope should not open for single-result")

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)
    end)
end)
