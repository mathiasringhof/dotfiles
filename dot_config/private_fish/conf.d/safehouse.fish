# safehouse.fish — framework for running commands inside Safehouse.
#
# Safehouse is a sandbox launcher: it runs a command with a restricted view of
# the filesystem plus an explicit env-var allow-list. This file builds that
# allow-list from layered sources and exposes helpers to extend it.
#
# Variable model (low -> high precedence), all rebuilt by __safehouse_rebuild:
#
#   SAFEHOUSE_BASE_ADD_DIRS_RO     read-only path defaults seeded by earlier
#   SAFEHOUSE_BASE_ADD_DIRS        conf.d files (e.g. abbvie.fish sets the work
#   SAFEHOUSE_BASE_APPEND_PROFILES CA bundle as a base read-only path).
#   SAFEHOUSE_BASE_ENV_PASS
#       +
#   SAFEHOUSE_EXTRA_RO             per-session additions made interactively via
#   SAFEHOUSE_EXTRA_RW             the safehouse-allow-* commands below, or by
#   SAFEHOUSE_EXTRA_APPEND_PROFILES later conf.d files (e.g. zz-safehouse-swift).
#   SAFEHOUSE_EXTRA_ENV_PASS
#       =
#   SAFEHOUSE_ADD_DIRS_RO          the final, de-duplicated values Safehouse
#   SAFEHOUSE_ADD_DIRS             actually reads. Do not set these by hand;
#   SAFEHOUSE_APPEND_PROFILES      set the BASE_*/EXTRA_* inputs and let
#   SAFEHOUSE_ENV_PASS             __safehouse_rebuild recompute them.
#
# Public API:
#   __safehouse_command CMD...     run CMD inside Safehouse with configured profiles
#   safehouse-allow-ro PATH...     add read-only path(s) for this session
#   safehouse-allow-rw PATH...     add read/write path(s) for this session
#   safehouse-allow-env VAR...     pass existing env var(s) through to Safehouse
#   safehouse-env-set VAR VALUE    set a var and pass it through
#   safehouse-env-pass VAR...      alias for safehouse-allow-env
#   safehouse-allow-list           show the current effective allow-list
#
# Consumers (e.g. pi.fish) build on __safehouse_command rather than calling
# `safehouse` directly, so profile handling stays in one place.

function __safehouse_command --description 'Run safehouse with shell-configured extra options'
    set -l args

    if set -q SAFEHOUSE_APPEND_PROFILES; and test -n "$SAFEHOUSE_APPEND_PROFILES"
        for profile in (string split : -- "$SAFEHOUSE_APPEND_PROFILES")
            set -a args --append-profile "$profile"
        end
    end

    command safehouse $args $argv
end

function __safehouse_split_paths --description 'Split colon-separated Safehouse path vars'
    for value in $argv
        if test -n "$value"
            string split : -- "$value"
        end
    end
end

function __safehouse_unique_paths --description 'Print unique non-empty paths in order'
    set -l unique
    for path in $argv
        if test -n "$path"; and not contains -- "$path" $unique
            set -a unique "$path"
        end
    end
    printf '%s\n' $unique
end

function __safehouse_split_csv --description 'Split comma-separated Safehouse vars'
    for value in $argv
        if test -n "$value"
            string split , -- "$value" | string trim
        end
    end
end

function __safehouse_unique_items --description 'Print unique non-empty items in order'
    set -l unique
    for item in $argv
        if test -n "$item"; and not contains -- "$item" $unique
            set -a unique "$item"
        end
    end
    printf '%s\n' $unique
end

function __safehouse_rebuild --description 'Rebuild Safehouse allow-list env vars'
    set -l ro_unique (__safehouse_unique_paths \
        (__safehouse_split_paths "$SAFEHOUSE_BASE_ADD_DIRS_RO") \
        $SAFEHOUSE_EXTRA_RO)

    if test (count $ro_unique) -gt 0
        set -gx SAFEHOUSE_ADD_DIRS_RO (string join : -- $ro_unique)
    else
        set -e SAFEHOUSE_ADD_DIRS_RO
    end

    set -l rw_unique (__safehouse_unique_paths \
        (__safehouse_split_paths "$SAFEHOUSE_BASE_ADD_DIRS") \
        $SAFEHOUSE_EXTRA_RW)

    if test (count $rw_unique) -gt 0
        set -gx SAFEHOUSE_ADD_DIRS (string join : -- $rw_unique)
    else
        set -e SAFEHOUSE_ADD_DIRS
    end

    set -l profile_unique (__safehouse_unique_paths \
        (__safehouse_split_paths "$SAFEHOUSE_BASE_APPEND_PROFILES") \
        $SAFEHOUSE_EXTRA_APPEND_PROFILES)

    if test (count $profile_unique) -gt 0
        set -gx SAFEHOUSE_APPEND_PROFILES (string join : -- $profile_unique)
    else
        set -e SAFEHOUSE_APPEND_PROFILES
    end

    set -l env_pass_unique (__safehouse_unique_items \
        (__safehouse_split_csv "$SAFEHOUSE_BASE_ENV_PASS") \
        (__safehouse_split_csv "$SAFEHOUSE_ENV_PASS") \
        $SAFEHOUSE_EXTRA_ENV_PASS)

    if test (count $env_pass_unique) -gt 0
        set -gx SAFEHOUSE_ENV_PASS (string join , -- $env_pass_unique)
    else
        set -e SAFEHOUSE_ENV_PASS
    end
end

function __safehouse_normalize_path --description 'Normalize a path for Safehouse allow-list vars'
    for path in $argv
        if string match -q '*:*' -- "$path"
            echo "safehouse allow paths cannot contain ':' because Safehouse uses ':' as the separator: $path" >&2
            return 1
        end

        path resolve -- "$path" 2>/dev/null
        or echo "$path"
    end
end

function __safehouse_add_symlink_literal_profile --description 'Add a literal-read profile for symlink allow paths'
    set -l raw_path "$argv[1]"
    set -l normalized "$argv[2]"

    if test -L "$raw_path"; and test "$raw_path" != "$normalized"
        set -l profile_dir "$HOME/.config/safehouse"
        set -l profile "$profile_dir/symlink-literals.sb"
        command mkdir -p "$profile_dir" 2>/dev/null

        set -l escaped (string replace -a '\\' '\\\\' -- "$raw_path" | string replace -a '"' '\\"')
        set -l rule "(allow file-read* (literal \"$escaped\"))"

        if not test -f "$profile"; or not string match -q -e -- "$rule" (string collect < "$profile")
            printf '%s\n' "$rule" >> "$profile"
        end

        contains -- "$profile" $SAFEHOUSE_EXTRA_APPEND_PROFILES
        or set -g SAFEHOUSE_EXTRA_APPEND_PROFILES $SAFEHOUSE_EXTRA_APPEND_PROFILES "$profile"
    end
end

function safehouse-allow-ro --description 'Add read-only paths for this shell session'
    if test (count $argv) -eq 0
        echo "usage: safehouse-allow-ro PATH [PATH ...]" >&2
        return 2
    end

    for path in $argv
        set -l normalized (__safehouse_normalize_path "$path")
        or return $status

        __safehouse_add_symlink_literal_profile "$path" "$normalized"

        contains -- "$normalized" $SAFEHOUSE_EXTRA_RO
        or set -g SAFEHOUSE_EXTRA_RO $SAFEHOUSE_EXTRA_RO "$normalized"
    end

    __safehouse_rebuild
    safehouse-allow-list
end

function safehouse-allow-rw --description 'Add read/write paths for this shell session'
    if test (count $argv) -eq 0
        echo "usage: safehouse-allow-rw PATH [PATH ...]" >&2
        return 2
    end

    for path in $argv
        set -l normalized (__safehouse_normalize_path "$path")
        or return $status

        __safehouse_add_symlink_literal_profile "$path" "$normalized"

        contains -- "$normalized" $SAFEHOUSE_EXTRA_RW
        or set -g SAFEHOUSE_EXTRA_RW $SAFEHOUSE_EXTRA_RW "$normalized"
    end

    __safehouse_rebuild
    safehouse-allow-list
end

function __safehouse_validate_env_name --description 'Validate an environment variable name'
    set -l name "$argv[1]"

    if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- "$name"
        echo "safehouse env names must look like shell variable names: $name" >&2
        return 1
    end
end

function safehouse-allow-env --description 'Pass environment variables through Safehouse for this shell session'
    if test (count $argv) -eq 0
        echo "usage: safehouse-allow-env VAR [VAR ...]" >&2
        return 2
    end

    for name in $argv
        __safehouse_validate_env_name "$name"
        or return $status

        if set -q $name; and not set -qx $name
            set -gx $name $$name
        end

        contains -- "$name" $SAFEHOUSE_EXTRA_ENV_PASS
        or set -g SAFEHOUSE_EXTRA_ENV_PASS $SAFEHOUSE_EXTRA_ENV_PASS "$name"
    end

    __safehouse_rebuild
    safehouse-allow-list
end

function safehouse-env-set --description 'Set and pass an environment variable through Safehouse for this shell session'
    if test (count $argv) -lt 2
        echo "usage: safehouse-env-set VAR VALUE" >&2
        return 2
    end

    set -l name "$argv[1]"
    __safehouse_validate_env_name "$name"
    or return $status

    set -e argv[1]
    set -gx $name "$argv"

    contains -- "$name" $SAFEHOUSE_EXTRA_ENV_PASS
    or set -g SAFEHOUSE_EXTRA_ENV_PASS $SAFEHOUSE_EXTRA_ENV_PASS "$name"

    __safehouse_rebuild
    safehouse-allow-list
end

function safehouse-env-pass --description 'Alias for safehouse-allow-env'
    safehouse-allow-env $argv
end

function safehouse-allow-list --description 'Show Safehouse paths and env vars that will be passed to safehouse'
    __safehouse_rebuild

    echo "read-only:"
    if set -q SAFEHOUSE_ADD_DIRS_RO
        for path in (string split : -- "$SAFEHOUSE_ADD_DIRS_RO")
            echo "  $path"
        end
    else
        echo "  <none>"
    end

    echo "read/write:"
    if set -q SAFEHOUSE_ADD_DIRS; and test -n "$SAFEHOUSE_ADD_DIRS"
        for path in (string split : -- "$SAFEHOUSE_ADD_DIRS")
            echo "  $path"
        end
    else
        echo "  <none>"
    end

    echo "append profiles:"
    if set -q SAFEHOUSE_APPEND_PROFILES; and test -n "$SAFEHOUSE_APPEND_PROFILES"
        for path in (string split : -- "$SAFEHOUSE_APPEND_PROFILES")
            echo "  $path"
        end
    else
        echo "  <none>"
    end

    echo "env pass:"
    if set -q SAFEHOUSE_ENV_PASS; and test -n "$SAFEHOUSE_ENV_PASS"
        for name in (string split , -- "$SAFEHOUSE_ENV_PASS")
            if set -qx $name
                echo "  $name"
            else if set -q $name
                echo "  $name (set, not exported)"
            else
                echo "  $name (not set)"
            end
        end
    else
        echo "  <none>"
    end
end

# Preserve any company/project defaults set by earlier conf.d files as base paths.
if set -q SAFEHOUSE_ADD_DIRS_RO; and not set -q SAFEHOUSE_BASE_ADD_DIRS_RO
    set -gx SAFEHOUSE_BASE_ADD_DIRS_RO "$SAFEHOUSE_ADD_DIRS_RO"
end
if set -q SAFEHOUSE_ADD_DIRS; and not set -q SAFEHOUSE_BASE_ADD_DIRS
    set -gx SAFEHOUSE_BASE_ADD_DIRS "$SAFEHOUSE_ADD_DIRS"
end
if set -q SAFEHOUSE_APPEND_PROFILES; and not set -q SAFEHOUSE_BASE_APPEND_PROFILES
    set -gx SAFEHOUSE_BASE_APPEND_PROFILES "$SAFEHOUSE_APPEND_PROFILES"
end
if set -q SAFEHOUSE_ENV_PASS; and not set -q SAFEHOUSE_BASE_ENV_PASS
    set -gx SAFEHOUSE_BASE_ENV_PASS "$SAFEHOUSE_ENV_PASS"
end

__safehouse_rebuild
