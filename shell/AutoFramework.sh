#!/bin/sh
#  AutoFramework.sh
#  Created by zfeng on 2019-02-18.
#  Copyright © 2019年 guange. All rights reserved.

#使用xcode 环境变量 BUILD_ROOT WRAPPER_EXTENSION EXECUTABLE_PATH EXECUTABLE_FOLDER_PATH EXECUTABLE_NAME


if [ "${WRAPPER_EXTENSION}" != "framework" ]
then
echo "This shell only use the framework"
exit 0;
fi

ROOT=${BUILD_ROOT}

CONFIG="Release"

SIMULATOR="${CONFIG}-iphonesimulator"

DEVICE="${CONFIG}-iphoneos"

PRODUCT_SIMULATOR_DIR="${ROOT}/${SIMULATOR}"
PRODUCT_DEVICE_DIR="${ROOT}/${DEVICE}"

LIPO_SIMULATOR_PATH="${PRODUCT_SIMULATOR_DIR}/${EXECUTABLE_PATH}"
LIPO_DEVICE_PATH="${PRODUCT_DEVICE_DIR}/${EXECUTABLE_PATH}"

LIPO_PRODUCT_FOLDER="${PRODUCT_DEVICE_DIR}/${EXECUTABLE_FOLDER_PATH}"

PRODUCT_OUTPUT_DIR=$1

LIPO_OUTPUT_PATH="${PRODUCT_OUTPUT_DIR}/${EXECUTABLE_PATH}"

echo "Checking Files..."

if [ -f "$LIPO_SIMULATOR_PATH" ]
then
    lipo -info $LIPO_SIMULATOR_PATH
else
    echo "this file not find > ${LIPO_SIMULATOR_PATH}"
exit 0;
fi

if [ -f "$LIPO_DEVICE_PATH" ]
then
    lipo -info $LIPO_DEVICE_PATH
else
    echo "this file not find > ${LIPO_DEVICE_PATH}"
exit 0;
fi

if [ ! -d "$PRODUCT_OUTPUT_DIR" ]
then
    echo "this file not find > ${PRODUCT_OUTPUT_DIR}"
exit 0;
fi

echo "Use Config(${CONFIG}) Start Merge... "

cp -R ${LIPO_PRODUCT_FOLDER} ${PRODUCT_OUTPUT_DIR}

lipo -create ${LIPO_SIMULATOR_PATH} ${LIPO_DEVICE_PATH} -output ${LIPO_OUTPUT_PATH}

lipo -info ${LIPO_OUTPUT_PATH}

echo "End Merge..."
