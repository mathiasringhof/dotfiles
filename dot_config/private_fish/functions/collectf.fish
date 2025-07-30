function collectf -d 'Collect directory into JSON (-v for verbose notices)'
    # -------- configurable lists -------------------------------------------
    set -l skip_files .DS_Store .vaultpass          # always-skip basenames
    # -----------------------------------------------------------------------

    # -------- flag parsing --------------------------------------------------
    set -l verbose 0                                # default: quiet
    argparse v/verbose -- $argv; or return
    if set -q _flag_v
        set verbose 1
    end
    # -----------------------------------------------------------------------

    set -l tmp (mktemp)

    for file in (find . -type f -not -path '*/.git/*')
        set -l relpath (string replace -r '^\./' '' -- $file)
        set -l base (basename -- $relpath)

        # skip: explicit filenames
        if contains -- $base $skip_files
            test $verbose = 1; and echo "Skipping $relpath (skip_files)" >&2
            continue
        end

        # skip: crude binary detection (has NUL byte)
        if string match -q '*\x00*' < $file
            test $verbose = 1; and echo "Skipping binary $relpath" >&2
            continue
        end

        # emit one safely-escaped JSON object for this file
        jq -Rs --arg path "$relpath" '{path:$path, content:.}' < $file >> $tmp
    end

    # wrap all objects in a single JSON array
    jq -s '.' $tmp
    rm $tmp
end
