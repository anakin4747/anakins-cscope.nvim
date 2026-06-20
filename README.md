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
or for the Linux kernel:
```sh
make cscope
```

Then hook these into your own logic or your own keymaps:

```lua
local ac = require('anakins-cscope')

-- assumes <cword>
ac.goto_definition()
ac.goto_incoming_calls()
ac.goto_outgoing_calls()
ac.references()

-- explicit symbol
ac.goto_definition('setup_arch')
ac.goto_incoming_calls('setup_arch')
ac.goto_outgoing_calls('setup_arch')
ac.references('setup_arch')
```

Also take a look at `tests/dev/init.lua` used in the demo.

# demo

Run `make demo` to try it out in a container. Note that this only works for
symbols used in the test fixtures.

# todos

- skip waits in tests

# TDD as always

To run the tests for this application always just run `make` without arguments:

```sh
make
```
```
[+] Building 0.6s (11/11) FINISHED                                                                                                                             docker:default
 => [internal] load build definition from Dockerfile                                                                                                                     0.0s
 => => transferring dockerfile: 739B                                                                                                                                     0.0s
 => [internal] load metadata for docker.io/library/archlinux:base-20260111.0.480139                                                                                      0.4s
 => [internal] load .dockerignore                                                                                                                                        0.0s
 => => transferring context: 2B                                                                                                                                          0.0s
 => [1/6] FROM docker.io/library/archlinux:base-20260111.0.480139@sha256:417aa2d3e8e4cc8377360a94bf48ae1ed38e593cbecfcb34feb16d57e3efa1b5                                0.0s
 => => resolve docker.io/library/archlinux:base-20260111.0.480139@sha256:417aa2d3e8e4cc8377360a94bf48ae1ed38e593cbecfcb34feb16d57e3efa1b5                                0.0s
 => [internal] load build context                                                                                                                                        0.0s
 => => transferring context: 205B                                                                                                                                        0.0s
 => CACHED [2/6] RUN pacman -Syu --noconfirm     cloc     cocogitto     curl     git     jq     make     neovim     sudo     which                                       0.0s
 => CACHED [3/6] COPY plenary-patches /plenary-patches                                                                                                                   0.0s
 => CACHED [4/6] RUN mkdir -p /usr/local/share/nvim/site/pack/plenary/start &&     cd /usr/local/share/nvim/site/pack/plenary/start &&     git clone --depth 1 https://  0.0s
 => CACHED [5/6] RUN mkdir -p /usr/local/share/nvim/site/pack/telescope/start &&     cd /usr/local/share/nvim/site/pack/telescope/start &&     git clone --depth 1 http  0.0s
 => CACHED [6/6] RUN pacman -S --noconfirm cscope                                                                                                                        0.0s
 => exporting to image                                                                                                                                                   0.1s
 => => exporting layers                                                                                                                                                  0.0s
 => => exporting manifest sha256:e51806e77d2e29ada358991cb6c78740eeb553dd27f4f5664a2260a608923bea                                                                        0.0s
 => => exporting config sha256:f0a955212323844d28d10b5bcd978618ff6a2f220e5bfbeb74fb033d74fa1172                                                                          0.0s
 => => exporting attestation manifest sha256:bff8a1409d053fc4f4ce474f0555c8b56184314f9bda2a93c47f3f215cb9d3f9                                                            0.0s
 => => exporting manifest list sha256:6d3b958ef6f2882e9071bfaf21b205dec13d1969ffc85c59a89515b9c18e2a2c                                                                   0.0s
 => => naming to docker.io/library/cqfd_kin_anakin4747_anakins-cscope_5f7f52a:latest                                                                                     0.0s
 => => unpacking to docker.io/library/cqfd_kin_anakin4747_anakins-cscope_5f7f52a:latest                                                                                  0.0s

cloc:
 app:           files   blank   comment code
  lua           1       28      0       116
 tests:
  lua           3       91      0       380

No errored commits

Starting...Scheduling: tests/anakins-cscope_spec.lua

========================================
Testing: /home/kin/src/anakins-cscope.nvim/tests/anakins-cscope_spec.lua
SUCCESS anakins-cscope.goto_incoming_calls can be called without errors
SUCCESS anakins-cscope.goto_incoming_calls accepts a symbol as an argument
SUCCESS anakins-cscope.goto_incoming_calls opens init/main.c when passed rest_init
SUCCESS anakins-cscope.goto_incoming_calls goes to init/main.c:1210 when passed rest_init
SUCCESS anakins-cscope.goto_incoming_calls opens telescope picker with 2 results for do_one_initcall
SUCCESS anakins-cscope.goto_incoming_calls does nothing for start_kernel which has no callers
SUCCESS anakins-cscope.goto_incoming_calls selecting first do_one_initcall entry lands on init/main.c:1444
SUCCESS anakins-cscope.goto_incoming_calls jumps from cursor on rest_init definition
SUCCESS anakins-cscope.goto_outgoing_calls can be called without errors
SUCCESS anakins-cscope.goto_outgoing_calls accepts a symbol as an argument
SUCCESS anakins-cscope.goto_outgoing_calls opens init/main.c when passed do_trace_initcall_level
SUCCESS anakins-cscope.goto_outgoing_calls goes to init/main.c:1368 when passed do_trace_initcall_level
SUCCESS anakins-cscope.goto_outgoing_calls opens telescope picker with 2 results for try_to_run_init_process
SUCCESS anakins-cscope.goto_outgoing_calls selecting first try_to_run_init_process entry lands on init/main.c:1510
SUCCESS anakins-cscope.goto_outgoing_calls jumps from cursor on do_trace_initcall_level definition
SUCCESS anakins-cscope.goto_outgoing_calls does nothing for parse_args which has no outgoing calls
SUCCESS anakins-cscope.references can be called without errors
SUCCESS anakins-cscope.references accepts a symbol as an argument
SUCCESS anakins-cscope.references opens init/main.c when passed add_latent_entropy
SUCCESS anakins-cscope.references goes to init/main.c:1397 when passed add_latent_entropy
SUCCESS anakins-cscope.references opens telescope picker with 5 results for try_to_run_init_process
SUCCESS anakins-cscope.references selecting first try_to_run_init_process entry lands on init/main.c:1506
SUCCESS anakins-cscope.references does nothing for nonexistent_symbol_xyz which has no results
SUCCESS anakins-cscope.goto_definition can be called without errors
SUCCESS anakins-cscope.goto_definition accepts a symbol as an argument
SUCCESS anakins-cscope.goto_definition opens include/linux/regmap.h when passed regmap_reg_range
SUCCESS anakins-cscope.goto_definition goes to include/linux/regmap.h:234 when passed regmap_reg_range
SUCCESS anakins-cscope.goto_definition opens include/linux/regmap.h when cursor on regmap_reg_range
SUCCESS anakins-cscope.goto_definition goes to include/linux/regmap.h:234 when cursor on regmap_reg_range
SUCCESS anakins-cscope.goto_definition opens telescope picker with 2 results for setup_arch
SUCCESS anakins-cscope.goto_definition jumps directly for single-result symbols
SUCCESS anakins-cscope.goto_definition display includes code line content for each result
SUCCESS anakins-cscope.goto_definition selecting arm telescope entry lands on column 13
SUCCESS anakins-cscope.goto_definition selecting x86 telescope entry lands on column 13
SUCCESS anakins-cscope.goto_definition telescope picker shows a previewer window for multi-result queries
SUCCESS anakins-cscope.parse_results returns empty list for empty stdout
SUCCESS anakins-cscope.parse_results returns empty list for nil stdout
SUCCESS anakins-cscope.parse_results parses single result from cscope stdout
SUCCESS anakins-cscope.parse_results parses multiple results for setup_arch
SUCCESS anakins-cscope.parse_results skips lines that don't match the pattern
SUCCESS anakins-cscope.cwd_is_nil errors when cwd is nil and single result is jumped to
========================================
SUCCESS 41
FAILED  0
ERRORS  0
========================================
```
