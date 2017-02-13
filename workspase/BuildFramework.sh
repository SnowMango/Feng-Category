#!/bin/sh

#  BuildFramework.sh
#  CocoapodsDemo
#
#  Created by zhengfeng on 17/2/10.
#  Copyright © 2017年 zhengfeng. All rights reserved.


cd `dirname $0`

frameworkfile="Build-framework.feng"

outputfile="myOutputfile"

#从${frameworkfile}文件中读取需要编译的target
for framework in `cat ${frameworkfile}`
do

xcodebuild -workspace MyWorkspace.xcworkspace -scheme ${framework} -configuration ${CONFIGURATION} -sdk ${SDK_NAME} clean build

done

ALL_BUILD_FILE=`ls ${CONFIGURATION_BUILD_DIR}`
APP_PRODUCT="${TARGET_NAME}.app"

SOURCE_PATH="${CONFIGURATION_BUILD_DIR}"
DESTINATION_PATH="${CONFIGURATION_BUILD_DIR}/$APP_PRODUCT"

source_install()
{
    source_file=$0
    #copy bundle
    cp -R ${SOURCE_PATH}/$source_file ${DESTINATION_PATH}/$source_file
    #remove info.plist
    rm -rf ${DESTINATION_PATH}/$source_file/info.plist
    #remove 签名
    rm -rf ${DESTINATION_PATH}/$source_file/_CodeSignature
    #remove 可执行文件
    rm -rf ${DESTINATION_PATH}/$source_file/$source_file

}


for file in ${ALL_BUILD_FILE}
do
    if [[ ${file} == *\.bundle ]]; then
cat << EOF >> ${outputfile}
copy ${file}
EOF
    source_install $file
    fi
done

open ${outputfile}


