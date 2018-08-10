#!/bin/sh
#  copyfiles.sh
#  Created by zhengfeng on 2018-08-09.
#  Copyright © 2018年 guange. All rights reserved.

SRC="$1"
DEST="$2"

echo "============= start ==========="
echo "cp -R $SRC $DEST"

cd /
cp -R $SRC $DEST
/usr/bin/open $SRC
echo "============= end ==========="
