#!/bin/sh
#  shell.sh
#  Created by zhengfeng on 17/3/8.
#  Copyright © 2017年 guange. All rights reserved.

set -e

FILE_SUF="lua"

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

cat << EOF >$FILE_ROOT/$FILE_NAME
#!/usr/local/bin/lua
EOF
