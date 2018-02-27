#!/bin/sh
#  compare-xctemplate.sh
#  Created by zhengfeng on 2017-03-16.
#  Copyright © 2017年 guange. All rights reserved.


set -e

for flag in "$@"
do
    case $flag in
        --beta)
        BETA=true
    shift  # Shift past argument with no value.
    ;;
    *)
    encho "can use --beta install Xcode-beta"
    ;;
    esac
done

TEMPLATE_PATH="`dirname $0`/iOS Bundle.xctemplate"
echo "$TEMPLATE_PATH"

if [ "${BETA}" = true ]
then
TEMPLATE_PROJECT_PATH="/Applications/Xcode.app-beta/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/Project Templates/iOS/Framework & Library"
else
TEMPLATE_PROJECT_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/Project Templates/iOS/Framework & Library"
fi

sudo cp -R "$TEMPLATE_PATH" "$TEMPLATE_PROJECT_PATH"
