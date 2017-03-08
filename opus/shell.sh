#!/bin/sh
#  shell.sh
#  Created by zhengfeng on 17/3/8.
#  Copyright © 2017年 guange. All rights reserved.

set -e
FILE_PATH="$1"
FILE_ROOT=`dirname $FILE_PATH`
FILE_NAME=`basename $FILE_PATH`

if [ "$FILE_ROOT" == "." ]
then
    FILE_PATH="$FILE_NAME"
fi

if [ "$FILE_ROOT" == "." ]
then
    exit 1
fi

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
