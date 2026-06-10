---
name: bash-syntax
description: Bash coding conventions: manual error handling instead of set -e, safe patterns for commands and scripts
---

## Never use set -* options

Do not use `set -e`, `set -u`, `set -o pipefail`, or any `set -*` option. Every error must be handled manually and explicitly.

## Manual error handling

Wrap every significant command in an explicit check. Define a `die` helper early in the script:

```bash
die() {
    printf "error: %s\n" "$1" >&2
    exit 1
}
```

### Short commands

```bash
if ! <command>; then
    die "<command> failed"
fi
```

### Long commands with line continuations

The `then` goes on its own line after the `;`:

```bash
if ! <command> \
    --long-arg1 \
    --long-arg2;
then
    die "<command> failed"
fi
```

### Subshells

If a block runs in a `( )` subshell, each command inside must be checked individually:

```bash
(
    if ! cd "${dir}"; then
        die "failed to cd to ${dir}"
    fi
    if ! cscope -bqkvR; then
        die "cscope rebuild failed"
    fi
)
```

## Output and communication

- Use `printf` for all output. Prefer `printf "error: ..." >&2` for errors.
- Error messages go to stderr and start with `"error: "`.
- Success messages go to stdout with a clear verb prefix like `"done: "`.
- Usage strings go to stderr and use `>&2`.

## Prefer long options

Use long option names (`--quiet`, `--recursive`, `--exclude`) over short ones (`-q`, `-r`, `-e`) in scripts. Long options are self-documenting and make the intent clear without consulting man pages. The exception is when short options make more sense — for example, in a tight interactive one-liner, a well-known combination like `rm -rf`, or when combining many single-letter flags where the long forms would be excessively verbose.

## Variable conventions

- Use lowercase for local script variables (`src_file`, `dest_dir`).
- Use `: "${VAR:=default}"` for optional environment variables with defaults.
- Quote all variable expansions (`"$var"`, not `$var`) unless word-splitting is explicitly desired.
- Use `$(...)` over backticks for command substitution.

## Guard patterns

- Validate argument count early: `if [ $# -ne 1 ]; then ...`
- Check file existence before operating: `if [ ! -f "$src_file" ]; then ...`
- Validate path structure with `case` before stripping prefixes.
- Check that commands exist on the system before calling them.
