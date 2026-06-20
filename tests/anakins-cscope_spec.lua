
local cs = require("anakins-cscope")

cs.cwd = 'tests/fixtures/default/'

vim.fn.mkdir(vim.fn.getcwd() .. "/tests/logs", "p")

local delay = 100

local function _it(text, fn)
    cs.logfile = vim.fn.getcwd() .. "/tests/logs/" .. string.gsub(text, "[%s/:']", "-") .. ".log"
    cs.should_log = true
    it(text, fn)
end

describe("anakins-cscope.goto_incoming_calls", function()
    _it("can be called without errors", function()
        assert.has_no.errors(function()
            cs.goto_incoming_calls()
        end)
    end)

    _it("accepts a symbol as an argument", function()
        assert.has_no.errors(function()
            cs.goto_incoming_calls('rest_init')
        end)
    end)

    _it("opens init/main.c when passed rest_init", function()
        cs.goto_incoming_calls('rest_init')
        vim.wait(delay)
        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("init/main.c", name)
    end)

    _it("goes to init/main.c:1210 when passed rest_init", function()
        cs.goto_incoming_calls('rest_init')
        vim.wait(delay)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1210, row, "wrong row")
        assert.equal(1, col, "wrong column")
    end)

    _it("opens telescope picker with 2 results for do_one_initcall", function()
        cs.goto_incoming_calls('do_one_initcall')
        vim.wait(delay)
        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local picker = require("telescope.actions.state").get_current_picker(prompts[1])
        local entries = picker.finder.results
        assert.equal(2, #entries)
    end)

    _it("does nothing for start_kernel which has no callers", function()
        local before = #require("telescope.state").get_existing_prompt_bufnrs()
        cs.goto_incoming_calls('start_kernel')
        vim.wait(delay)
        local name = vim.api.nvim_buf_get_name(0)
        assert.equal("", name, "should not open any file")

        local after = #require("telescope.state").get_existing_prompt_bufnrs()
        assert.equal(before, after, "telescope count should not change")
    end)

    _it("selecting first do_one_initcall entry lands on init/main.c:1444", function()
        cs.goto_incoming_calls('do_one_initcall')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        require("telescope.actions").select_default(prompts[1])
        vim.wait(delay)

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("init/main.c", name)

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1444, row)
        assert.equal(1, col)
    end)

    _it("jumps from cursor on rest_init definition", function()
        vim.cmd.edit(cs.cwd .. "init/main.c")
        vim.api.nvim_win_set_cursor(0, { 714, 38 })
        cs.goto_incoming_calls()
        vim.wait(delay)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1210, row, "wrong row")
        assert.equal(1, col, "wrong column")
    end)
end)

describe("anakins-cscope.goto_outgoing_calls", function()
    _it("can be called without errors", function()
        assert.has_no.errors(function()
            cs.goto_outgoing_calls()
        end)
    end)

    _it("accepts a symbol as an argument", function()
        assert.has_no.errors(function()
            cs.goto_outgoing_calls('do_trace_initcall_level')
        end)
    end)

    _it("opens init/main.c when passed do_trace_initcall_level", function()
        cs.goto_outgoing_calls('do_trace_initcall_level')
        vim.wait(delay)
        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("init/main.c", name)
    end)

    _it("goes to init/main.c:1368 when passed do_trace_initcall_level", function()
        cs.goto_outgoing_calls('do_trace_initcall_level')
        vim.wait(delay)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1368, row, "wrong row")
        assert.equal(1, col, "wrong column")
    end)

    _it("opens telescope picker with 2 results for try_to_run_init_process", function()
        cs.goto_outgoing_calls('try_to_run_init_process')
        vim.wait(delay)
        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local picker = require("telescope.actions.state").get_current_picker(prompts[1])
        local entries = picker.finder.results
        assert.equal(2, #entries)
    end)

    _it("selecting first try_to_run_init_process entry lands on init/main.c:1510", function()
        cs.goto_outgoing_calls('try_to_run_init_process')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        require("telescope.actions").select_default(prompts[1])
        vim.wait(delay)

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("init/main.c", name)

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1510, row)
        assert.equal(7, col)
    end)

    _it("jumps from cursor on do_trace_initcall_level definition", function()
        vim.cmd.edit(cs.cwd .. "init/main.c")
        vim.api.nvim_win_set_cursor(0, { 1364, 20 })
        cs.goto_outgoing_calls()
        vim.wait(delay)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1368, row, "wrong row")
        assert.equal(1, col, "wrong column")
    end)

    _it("does nothing for parse_args which has no outgoing calls", function()
        local before = #require("telescope.state").get_existing_prompt_bufnrs()
        vim.cmd.new()
        cs.goto_outgoing_calls('parse_args')
        vim.wait(delay)
        local name = vim.api.nvim_buf_get_name(0)
        assert.equal("", name, "should not open any file")

        local after = #require("telescope.state").get_existing_prompt_bufnrs()
        assert.equal(before, after, "telescope count should not change")
    end)
end)

describe("anakins-cscope.references", function()
    _it("can be called without errors", function()
        assert.has_no.errors(function()
            cs.references()
        end)
    end)

    _it("accepts a symbol as an argument", function()
        assert.has_no.errors(function()
            cs.references('add_latent_entropy')
        end)
    end)

    _it("opens init/main.c when passed add_latent_entropy", function()
        cs.references('add_latent_entropy')
        vim.wait(delay)
        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("init/main.c", name)
    end)

    _it("goes to init/main.c:1397 when passed add_latent_entropy", function()
        cs.references('add_latent_entropy')
        vim.wait(delay)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1397, row, "wrong row")
        assert.equal(1, col, "wrong column")
    end)

    _it("opens telescope picker with 5 results for try_to_run_init_process", function()
        cs.references('try_to_run_init_process')
        vim.wait(delay)
        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local picker = require("telescope.actions.state").get_current_picker(prompts[1])
        local entries = picker.finder.results
        assert.equal(5, #entries)
    end)

    _it("selecting first try_to_run_init_process entry lands on init/main.c:1506", function()
        cs.references('try_to_run_init_process')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        require("telescope.actions").select_default(prompts[1])
        vim.wait(delay)

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("init/main.c", name)

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1506, row)
        assert.equal(12, col)
    end)

    _it("does nothing for nonexistent_symbol_xyz which has no results", function()
        local before = #require("telescope.state").get_existing_prompt_bufnrs()
        vim.cmd.new()
        cs.references('nonexistent_symbol_xyz')
        vim.wait(delay)
        local name = vim.api.nvim_buf_get_name(0)
        assert.equal("", name, "should not open any file")

        local after = #require("telescope.state").get_existing_prompt_bufnrs()
        assert.equal(before, after, "telescope count should not change")
    end)
end)

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
        vim.wait(delay)
        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)
    end)

    _it("goes to include/linux/regmap.h:234 when passed regmap_reg_range", function()
        cs.goto_definition('regmap_reg_range')
        vim.wait(delay)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(234, row, "wrong row")
        assert.equal(9, col, "wrong column")
    end)

    _it("opens include/linux/regmap.h when cursor on regmap_reg_range", function()
        vim.cmd.edit(cs.cwd .. "drivers/pmdomain/imx/gpc.c")
        vim.api.nvim_win_set_cursor(0, { 328, 3 })
        cs.goto_definition()
        vim.wait(delay)
        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)
    end)

    _it("goes to include/linux/regmap.h:234 when cursor on regmap_reg_range", function()
        vim.cmd.edit(cs.cwd .. "drivers/pmdomain/imx/gpc.c")
        vim.api.nvim_win_set_cursor(0, { 328, 3 })
        cs.goto_definition()
        vim.wait(delay)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(234, row, "wrong row")
        assert.equal(9, col, "wrong column")
    end)

    _it("opens telescope picker with 2 results for setup_arch", function()
        cs.goto_definition('setup_arch')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local picker = require("telescope.actions.state").get_current_picker(prompts[1])
        local entries = picker.finder.results
        assert.equal(2, #entries)
        assert.matches("arch/arm/kernel/setup.c", entries[1].value.filepath)
        assert.matches("arch/x86/kernel/setup.c", entries[2].value.filepath)
    end)

    _it("jumps directly for single-result symbols", function()
        cs.goto_definition('regmap_reg_range')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.equal(0, #prompts, "telescope should not open for single-result")

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)
    end)

    _it("display includes code line content for each result", function()
        cs.goto_definition('setup_arch')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local picker = require("telescope.actions.state").get_current_picker(prompts[1])
        local entries = picker.finder.results
        assert.equal(2, #entries)

        assert.matches("void __init setup_arch", entries[1].display)
        assert.matches("void __init setup_arch", entries[2].display)
    end)

    _it("selecting arm telescope entry lands on column 13", function()
        cs.goto_definition('setup_arch')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        require("telescope.actions").select_default(prompts[1])
        vim.wait(delay)

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("arch/arm/kernel/setup.c", name)

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(1096, row)
        assert.equal(13, col)
    end)

    _it("selecting x86 telescope entry lands on column 13", function()
        cs.goto_definition('setup_arch')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        assert.is_true(#prompts > 0, "telescope should have an active picker")

        local actions = require("telescope.actions")
        actions.move_selection_next(prompts[1])
        vim.wait(50)
        actions.select_default(prompts[1])
        vim.wait(delay)

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("arch/x86/kernel/setup.c", name)

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        assert.equal(884, row)
        assert.equal(13, col)
    end)

    _it("telescope picker shows a previewer window for multi-result queries", function()
        vim.o.columns = 200
        cs.goto_definition('setup_arch')
        vim.wait(delay)

        local prompts = require("telescope.state").get_existing_prompt_bufnrs()
        local picker = require("telescope.actions.state").get_current_picker(prompts[1])
        assert.is_true(vim.api.nvim_win_is_valid(picker.preview_win),
            "previewer window should be present and have a valid window")
    end)
end)

describe("anakins-cscope.parse_results", function()
    _it("returns empty list for empty stdout", function()
        local results = cs.parse_results("")
        assert.are.same({}, results)
    end)

    _it("returns empty list for nil stdout", function()
        local results = cs.parse_results(nil)
        assert.are.same({}, results)
    end)

    _it("parses single result from cscope stdout", function()
        cs.symbol = 'regmap_reg_range'
        local stdout = "include/linux/regmap.h regmap_reg_range 234 #define regmap_reg_range(low, high) { .range_min = low, .range_max = high, }\n"
        local results = cs.parse_results(stdout)
        assert.equal(1, #results)
        assert.equal("include/linux/regmap.h", results[1].filepath)
        assert.equal(234, results[1].row)
        assert.equal(9, results[1].column)
        assert.matches("regmap_reg_range", results[1].content)
    end)

    _it("parses multiple results for setup_arch", function()
        cs.symbol = 'setup_arch'
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

    _it("skips lines that don't match the pattern", function()
        cs.symbol = 'regmap_reg_range'
        local stdout = "short\ninclude/linux/regmap.h regmap_reg_range 234 #define regmap_reg_range(low, high) { .range_min = low, .range_max = high, }\n"
        local results = cs.parse_results(stdout)
        assert.equal(1, #results)
        assert.equal("include/linux/regmap.h", results[1].filepath)
    end)
end)

describe("anakins-cscope.cwd_is_nil", function()
    _it("errors when cwd is nil and single result is jumped to", function()
        local orig_cwd = cs.cwd
        cs.cwd = nil
        local orig_dir = vim.fn.getcwd()
        vim.cmd('cd tests/fixtures/default/')

        cs.goto_definition('regmap_reg_range')
        vim.wait(200)

        local name = vim.api.nvim_buf_get_name(0)
        assert.matches("include/linux/regmap.h", name)

        vim.cmd('cd ' .. orig_dir)
        cs.cwd = orig_cwd
    end)
end)



