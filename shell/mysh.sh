#! /bin/bash
cd `dirname $0`
name="UlucuFullPlayer"
#framework最终合并生成路径：WRK_DIR
WRK_DIR="./${name}.framework"
DEVICE_DIR="Release-iphoneos/$name.framework"
SIMULATOR_DIR="Release-iphonesimulator/$name.framework"
echo "checking files..."

if
[ -d "$SIMULATOR_DIR" ]
then
if
[ -d "$DEVICE_DIR" ]
then
cp -fr ${DEVICE_DIR} ${WRK_DIR}
rm -f $WRK_DIR/$name
echo "$name:start Merge..."
lipo -create "${DEVICE_DIR}/$name" "${SIMULATOR_DIR}/$name" -output "${WRK_DIR}/$name"
lipo -info ${WRK_DIR}/$name
[ -d "${WRK_DIR}/$name" ]&&echo "Framework generation success"
du -hs ${WRK_DIR}
open ${WRK_DIR}
else
echo "Framework generation failure reason:reason:the lack of necessary iphoneos files"
fi
else
echo "Framework generation failure reason:the lack of necessary iphonesimulator files"
fi




