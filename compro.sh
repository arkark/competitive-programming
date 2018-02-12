#!/bin/sh

# ./compro.sh a b
#  -> create temp/a.d, temp/b.d

folderName="temp"
templateFileName="template.d"

if [ -e $folderName ]; then
    echo "folder '$folderName' already exists"
else
    mkdir $folderName
    for fileName in $@; do
        cp $templateFileName "$folderName/$fileName.d"
    done
fi
