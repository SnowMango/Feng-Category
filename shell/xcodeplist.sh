#!/bin/sh

#  xcodeplist.sh
#
#  Created by zhengfeng on 17/3/8.
#  Copyright © 2017年 guange. All rights reserved.

set -e

FILE_SUF="plist"

FILE_PATH="$1"
FILE_ROOT=`dirname $FILE_PATH`
FILE_NAME=`basename $FILE_PATH .$FILE_SUF`

DISABLE_FILE=". .. .DS_Store"

for file in $DISABLE_FILE
do
    if [ "$FILE_NAME" == "$file" -o "$FILE_NAME" == "$file.$FILE_SUF" ]
    then
        exit 1
    fi
done

FILE_NAME="${FILE_NAME}.$FILE_SUF"

if [ "$FILE_ROOT" != "." -a "$FILE_ROOT" != "/" ]
then
    mkdir -p $FILE_ROOT
fi


cat << EOF >"$FILE_ROOT/$FILE_NAME"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>
EOF
