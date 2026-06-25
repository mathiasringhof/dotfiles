# pi.fish — workflow commands for running the `pi` agent inside Safehouse.
#
# Everything here is pi-specific and builds on the Safehouse framework defined
# in safehouse.fish (via __safehouse_command). The dependency is enforced at
# call time by __pi_require_safehouse rather than by conf.d load order: fish
# function bodies are lazy, so although pi.fish is sourced before safehouse.fish
# alphabetically, __safehouse_command is already defined by the time any command
# here actually runs.
#
# Commands:
#   p                run pi inside Safehouse in the current directory
#   pn [LABEL] ...   create a fresh git worktree/branch and start pi in it
#   pm               merge the current pi/* worktree branch into a merge/* branch
#   pconf ...        run pi from ~/.pi with read access to fish conf.d
#   pb ...           launch Chrome (CDP), then start pi-browser-harness in Safehouse

function __pi_require_safehouse --description 'Ensure the Safehouse framework is loaded'
    functions -q __safehouse_command
    or begin
        echo "pi.fish requires safehouse.fish (its __safehouse_command is not loaded)" >&2
        return 1
    end
end

function p --description 'Run pi inside Safehouse'
    __pi_require_safehouse
    or return

    __safehouse_command pi $argv
end

function __pi_git_slug --description 'Make a filesystem/branch-safe slug'
    string lower -- $argv | string replace -ra '[^a-z0-9._/-]+' '-' | string replace -ra '/+' '-' | string trim -c '-'
end

function __pi_git_primary_worktree --description 'Print the first non-current worktree path for this repository'
    set -l current (git rev-parse --show-toplevel 2>/dev/null)
    or return 1
    set current (path resolve -- $current)

    set -l candidates
    for line in (git worktree list --porcelain | string match -r '^worktree ')
        set -l wt (string replace -r '^worktree ' '' -- $line)
        set -l resolved (path resolve -- $wt 2>/dev/null; or echo $wt)
        if test "$resolved" != "$current"
            set -a candidates "$resolved"
        end
    end

    if test (count $candidates) -gt 0
        printf '%s\n' $candidates[1]
        return 0
    end

    printf '%s\n' $current
end

function pn --description 'Create a new git worktree/thread and start pi in it'
    __pi_require_safehouse
    or return

    set -l repo (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "pn: not inside a git repository" >&2
        return 1
    end

    set -l repo_name (basename $repo)
    set -l label $argv[1]
    if test -z "$label"
        set label thread
    end

    set -l slug (__pi_git_slug $label)
    set -l stamp (date +%Y%m%d-%H%M%S)
    set -l branch "pi/$slug-$stamp"
    set -l wt_root "$HOME/.pi/worktrees/$repo_name"
    set -l wt_path "$wt_root/$slug-$stamp"

    command mkdir -p "$wt_root"
    git -C "$repo" worktree add -b "$branch" "$wt_path"
    or return $status

    echo "pn: created $wt_path on branch $branch"
    set -l oldpwd $PWD
    cd "$wt_path"
    __safehouse_command pi $argv[2..-1]
    set -l status_code $status
    cd $oldpwd
    return $status_code
end

function pm --description 'Merge the current pi worktree branch into an automatically named branch in the primary worktree'
    set -l repo (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "pm: not inside a git repository" >&2
        return 1
    end

    set -l source_branch (git -C "$repo" branch --show-current)
    if test -z "$source_branch"
        echo "pm: current worktree is detached; checkout a branch first" >&2
        return 1
    end

    if not string match -q 'pi/*' -- "$source_branch"
        echo "pm: refusing to auto-merge non-pi branch '$source_branch'" >&2
        echo "pm: run from a pn-created pi/* worktree, or merge manually" >&2
        return 1
    end

    set -l dirty (git -C "$repo" status --porcelain)
    if test -n "$dirty"
        echo "pm: current worktree has uncommitted changes; commit or stash them first" >&2
        return 1
    end

    set -l primary (__pi_git_primary_worktree)
    or return $status

    set -l base_branch (git -C "$primary" branch --show-current)
    if test -z "$base_branch"
        echo "pm: primary worktree is detached: $primary" >&2
        return 1
    end

    set -l merge_slug (__pi_git_slug (string replace -r '^pi/' '' -- "$source_branch"))
    set -l merge_branch "merge/$merge_slug"

    git -C "$primary" switch -c "$merge_branch" "$base_branch"
    or return $status

    git -C "$primary" merge --no-ff "$source_branch"
    or begin
        echo "pm: merge needs attention in $primary on branch $merge_branch" >&2
        return $status
    end

    echo "pm: merged $source_branch into $merge_branch at $primary"
end

function pconf --description 'Start pi in ~/.pi safehouse with fish conf.d access'
    __pi_require_safehouse
    or return

    set -l oldpwd $PWD
    cd ~/.pi
    __safehouse_command --add-dirs ~/.config/fish/conf.d -- pi $argv
    set -l status_code $status
    cd $oldpwd
    return $status_code
end

function pb --description 'Start Chrome CDP, set BU_CDP_WS, then start pi-browser-harness in safehouse'
    __pi_require_safehouse
    or return

    set -l host 127.0.0.1
    set -l port 9222
    set -l profile_dir ~/.pi/chrome-cdp
    set -l chrome_app "Google Chrome"

    if set -q BU_CDP_PORT
        set port $BU_CDP_PORT
    end
    if set -q BU_CHROME_PROFILE
        set profile_dir $BU_CHROME_PROFILE
    end
    if set -q BU_CHROME_APP
        set chrome_app $BU_CHROME_APP
    end

    set -l url "http://$host:$port/json/version"

    command mkdir -p "$profile_dir"

    if not command python3 -c 'import json, sys, urllib.request
with urllib.request.urlopen(sys.argv[1], timeout=0.5) as r:
    json.load(r)["webSocketDebuggerUrl"]
' $url >/dev/null 2>&1
        if not command open -na "$chrome_app" --args \
                --remote-debugging-address=$host \
                --remote-debugging-port=$port \
                --user-data-dir=$profile_dir \
                about:blank
            echo "pb: failed to open '$chrome_app'. Set BU_CHROME_APP to your Chrome/Chromium app name." >&2
            return 1
        end
    end

    set -l ws (command python3 -c 'import json, sys, time, urllib.request
url = sys.argv[1]
last = None
for _ in range(50):
    try:
        with urllib.request.urlopen(url, timeout=0.5) as r:
            print(json.load(r)["webSocketDebuggerUrl"])
            sys.exit(0)
    except Exception as e:
        last = e
        time.sleep(0.1)
print(f"pb: failed to read {url}: {last}", file=sys.stderr)
sys.exit(1)
' $url)

    if test $status -ne 0
        return 1
    end

    set -gx BU_CDP_WS $ws
    echo "BU_CDP_WS=$BU_CDP_WS"

    set -l oldpwd $PWD
    cd ~/.pi
    __safehouse_command --enable=agent-browser --env-pass=BU_CDP_WS -- \
        pi --no-extensions --no-skills \
            -e /opt/homebrew/lib/node_modules/pi-browser-harness/src/index.ts \
            --skill /opt/homebrew/lib/node_modules/pi-browser-harness/skills/pi-browser-harness \
            $argv
    set -l status_code $status
    cd $oldpwd
    return $status_code
end
