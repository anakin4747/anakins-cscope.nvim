
local cs = require("anakins-cscope")

cs.cwd = 'tests/fixtures/default/'

local function _it(text, fn)
    cs.logfile = "tests/logs/" .. string.gsub(text, "[%s/:']", "-") .. ".log"
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
        assert.equal(8, results[1].column)
        assert.matches("regmap_reg_range", results[1].content)
    end)

    it("parses multiple results for setup_arch", function()
        local stdout = "arch/arm/kernel/setup.c setup_arch 1096 void __init setup_arch(char **cmdline_p)\narch/x86/kernel/setup.c setup_arch 884 void __init setup_arch(char **cmdline_p)\n"
        local results = cs.parse_results(stdout)
        assert.equal(2, #results)
        assert.equal("arch/arm/kernel/setup.c", results[1].filepath)
        assert.equal(1096, results[1].row)
        assert.equal(13, results[1].column)
        assert.equal("arch/x86/kernel/setup.c", results[2].filepath)
        assert.equal(884, results[2].row)
        assert.equal(13, results[2].column)
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
        cs.goto_definition('setup_arch')
        vim.wait(100)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local picker = require("telescope.actions.state").get_current_picker(prompts[1])
        local entries = picker.finder.results
        assert.equal(2, #entries)
        assert.matches("arch/arm/kernel/setup.c", entries[1].value.filepath)
        assert.matches("arch/x86/kernel/setup.c", entries[2].value.filepath)
    end)

    it("jumps directly for single-result symbols", function()
        cs.goto_definition('regmap_reg_range')
        vim.wait(100)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.equal(0, #prompts, "telescope should not open for single-result")

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)
    end)

    it("display includes code line content for each result", function()
        cs.goto_definition('setup_arch')
        vim.wait(100)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local picker = require("telescope.actions.state").get_current_picker(prompts[1])
        local entries = picker.finder.results
        assert.equal(2, #entries)

        assert.matches("void __init setup_arch", entries[1].display)
        assert.matches("void __init setup_arch", entries[2].display)
    end)

    it("selecting arm telescope entry lands on column 13", function()
        cs.goto_definition('setup_arch')
        vim.wait(100)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        require("telescope.actions").select_default(prompts[1])
        vim.wait(100)

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("arch/arm/kernel/setup.c", name)

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1096, row)
        assert.equal(13, col)
    end)

    it("selecting x86 telescope entry lands on column 13", function()
        cs.goto_definition('setup_arch')
        vim.wait(100)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local actions = require("telescope.actions")
        actions.move_selection_next(prompts[1])
        vim.wait(50)
        actions.select_default(prompts[1])
        vim.wait(100)

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("arch/x86/kernel/setup.c", name)

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(884, row)
        assert.equal(13, col)
    end)
end)
