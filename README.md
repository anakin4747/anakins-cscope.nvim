# anakins-cscope.nvim

Using cscope for lsp stuff like goto definition, references, incoming and
outgoing calls, etc.

Using cscope is just faster than clangd to get these features after a fresh
clone so I want to fallback to cscope if an lsp request fails.

This is a Neovim lua library for functions that you can use to use cscope when
your lsp fails you.

Depends on telescope for viewing multiple results.

# installation

Install how you would your plugins typically.

Here is what it looks like with `vim.pack`:

```lua
vim.pack.add({ 'https://github.com/anakin4747/anakins-cscope.nvim' })
```

# usage

Build the cscope database for your repo, with a command such as:
```sh
cscope -bqkvR
```

Then hook these into your own logic or your own keymaps:

```lua
local ac = require('anakins-cscope')

-- assumes <cword>
ac.goto_definition()
ac.goto_incoming_calls()
ac.goto_outgoing_calls()
ac.rename()

-- explicit symbol
ac.goto_definition('setup_arch')
ac.goto_incoming_calls('setup_arch')
ac.goto_outgoing_calls('setup_arch')
ac.rename('setup_arch')
```

# demo

Run `make demo` to try it out in a container. Note that this only works for
symbols used in the test fixtures.

# TDD as always

To run the tests for this application always just run `make` without arguments.

