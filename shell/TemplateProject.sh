#!/bin/sh
#  TemplateProject.sh
#  Created by zhengfeng on 2017-03-14.
#  Copyright © 2017年 guange. All rights reserved.


APP_PATH="Applications/Xcode.app/Contents"

TEMPLATE_PATH="Developer/Library/Xcode/Templates"

TEMPLATE_PROJECT="Project Templates"

FILE_PATH="/${APP_PATH}/${TEMPLATE_PATH}/${TEMPLATE_PROJECT}"

PLATFORMS="MacOSX iPhoneOS WatchOS AppleTVOS"

cd $FILE_PATH
FILE_SYSTEM=`ls`

for platform in $PLATFORMS
do


done


