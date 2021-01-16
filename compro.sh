#!/usr/bin/env bash

# ./compro.sh a b
#  -> Create workspace/a.d, workspace/b.d

set -eu

folderName="workspace"
templateFileName="$(git rev-parse --show-toplevel)/template.d"

if [ -e $folderName ]; then
    echo "Folder '$folderName' already exists"
else
    mkdir $folderName

    for fileName in $@; do
        cp $templateFileName "$folderName/$fileName.d"
    done

    printf "Input a contest URL: "
    read URL
    TASK_URL=$(echo $URL | sed -E 's/(^.*)\/([^\/]+)\/?$/\1\/\2\/tasks\/\2_/')

    printf "%s\n" \
        'command = "rdmd {}.d"'\
        '# command = "rdmd -m64 -O -release -inline -boundscheck=off {}.d"'\
        'file_name = "{}.d"' \
        "task_url = \"$TASK_URL{}\"" \
        > "$folderName/.config.toml"

    echo "Created:"
    find $folderName -not -type d
fi
