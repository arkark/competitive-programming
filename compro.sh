#!/bin/sh

# ./compro.sh a b
#  -> create dir/a.d, dir/b.d

folderName="dir"
templateFileName="template.d"

if [ -e $folderName ]; then
    echo "folder '$folderName' already exists"
else
    mkdir $folderName
    for fileName in $@; do
        cp $templateFileName "$folderName/$fileName.d"
    done
fi
