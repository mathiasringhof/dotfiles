# Make Apple Swift/Xcode available inside Safehouse.
#
# On macOS, /usr/bin/swift is only an xcrun shim. The real compiler lives under
# Xcode or Command Line Tools, so Safehouse needs those paths mounted.

set -l __swift_developer_dir

if test -d /Applications/Xcode.app/Contents/Developer
    set __swift_developer_dir /Applications/Xcode.app/Contents/Developer
else if test -d /Library/Developer/CommandLineTools
    set __swift_developer_dir /Library/Developer/CommandLineTools
end

if test -n "$__swift_developer_dir"
    set -gx DEVELOPER_DIR "$__swift_developer_dir"
end

# Read-only paths needed for xcrun/swift/SDK discovery inside Safehouse.
for p in \
    /Applications/Xcode.app \
    /Library/Developer \
    /System/Library \
    /usr/lib
    if test -e "$p"
        set -l resolved (path resolve -- "$p" 2>/dev/null)

        if test -z "$resolved"
            set resolved "$p"
        end

        contains -- "$resolved" $SAFEHOUSE_EXTRA_RO
        or set -g SAFEHOUSE_EXTRA_RO $SAFEHOUSE_EXTRA_RO "$resolved"
    end
end

# Writable SwiftPM state/cache. This is not strictly required just to find
# `swift`, but it prevents later `swift build` failures when dependencies/cache
# need to be written.
for p in \
    "$HOME/.swiftpm" \
    "$HOME/Library/Caches/org.swift.swiftpm" \
    "$HOME/Library/org.swift.swiftpm"
    command mkdir -p "$p" 2>/dev/null

    if test -d "$p"
        set -l resolved (path resolve -- "$p" 2>/dev/null)

        if test -z "$resolved"
            set resolved "$p"
        end

        contains -- "$resolved" $SAFEHOUSE_EXTRA_RW
        or set -g SAFEHOUSE_EXTRA_RW $SAFEHOUSE_EXTRA_RW "$resolved"
    end
end

# Make sure Safehouse passes the Xcode selection through.
set -l __safehouse_env_pass

if set -q SAFEHOUSE_ENV_PASS; and test -n "$SAFEHOUSE_ENV_PASS"
    set __safehouse_env_pass (string split , -- "$SAFEHOUSE_ENV_PASS")
end

for name in DEVELOPER_DIR SDKROOT TOOLCHAINS
    if set -q $name
        contains -- "$name" $__safehouse_env_pass
        or set -a __safehouse_env_pass "$name"
    end
end

if test (count $__safehouse_env_pass) -gt 0
    set -gx SAFEHOUSE_ENV_PASS (string join , -- $__safehouse_env_pass)
end

# Rebuild final SAFEHOUSE_ADD_DIRS_RO / SAFEHOUSE_ADD_DIRS if your safehouse.fish
# helper has already been loaded.
if functions -q __safehouse_rebuild
    __safehouse_rebuild
end
