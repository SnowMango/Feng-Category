#!/bin/sh
#  shell.sh
#  Created by zhengfeng on 17/3/8.
#  Copyright © 2017年 guange. All rights reserved.

set -e

shell_create()
{
    FILE_PATH="$1"
    FILE_ROOT=`dirname $FILE_PATH`
    FILE_NAME=`basename $FILE_PATH`
    DISABLE_FILE=". .. .DS_Store"

    for file in $DISABLE_FILE
    do
        if [ "$FILE_NAME" == "$file" ]
        then
            exit 1
        fi
    done

    if [ "$FILE_ROOT" != "." -a "$FILE_ROOT" != "/" ]
    then
        mkdir -p $FILE_ROOT
    fi

    cat << EOF >$FILE_PATH
#!/bin/sh
#  $FILE_NAME
#  Created by `logname` on `date +%F`.
#  Copyright © `date +%Y`年 guange. All rights reserved.
EOF
chmod +x $FILE_PATH
}
ALL_OPT="create"
TAR=`echo ${ALL_OPT[@]} | grep -w "$1"`
TARS=("$@")
if [ -n "$TAR" ]
then
    shell_$1 ${TARS[@]:1}
else
    echo "============opt=============="
    for opt in $ALL_OPT
    do
        echo "  $opt"
    done
    echo "============opt=============="
fi
