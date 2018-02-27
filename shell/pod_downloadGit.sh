#!/bin/sh
#使用方法 xxx.sh 参数1 参数2
#参数1：Github:网址(url)/文件(.git)/下载地址(.zip)
#参数2：文件下载后存放目录
#eg: two_downloadGit.sh https://github.com/robbiehanson/CocoaAsyncSocket.git ~/Desktop

#检查shell传入参数
if [ $# -ne 2 ];then
echo "error parameter"
exit 1;
fi
GITHUB_URL=$1
INPUT_URL=$GITHUB_URL
INPUT_DIR=$2
#获取URL最后一级及其后缀
URL_LAST="${INPUT_URL##*/}"
URL_LAST_SUF="${URL_LAST#*.}"
#检查后缀类型
if [ "$URL_LAST_SUF" = "git" ];then
DOWNLOAD_URL="${INPUT_URL%.*}/archive/master.zip"
elif [ "$URL_LAST_SUF" = "zip" ];then
DOWNLOAD_URL="${INPUT_URL}"
elif [ "$URL_LAST_SUF" = "$URL_LAST" ];then
DOWNLOAD_URL="${INPUT_URL}/archive/master.zip"
else
exit 2
fi
echo "Download url:$DOWNLOAD_URL"
#从URL中取出下载文件名
LOCAL_NAME="${DOWNLOAD_URL%/archive/master.zip*}"
LOCAL_NAME="${LOCAL_NAME##*/}"

echo "Ready to downlaod $LOCAL_NAME files"
#设置临时文件名
REAL_DOWNLOAD_FILE="${LOCAL_NAME}.zfeng.download"

cd $INPUT_DIR
#下载包含真实路径的临时文件
curl -o $REAL_DOWNLOAD_FILE $DOWNLOAD_URL

#读取临时文件，获得最终下载地址
cat "$REAL_DOWNLOAD_FILE" | grep -i 'href' | sed -e 's/.*="//g' | sed -e 's/".*//g' | while read REAL_URL
do
[ -z $REAL_URL ]&&[ -f '${INPUT_DIR}/${LOCAL_NAME}.zip' ]&&continue
echo "Real download url:$REAL_URL"
#下载最终文件
curl -o "${LOCAL_NAME}.zip" "$REAL_URL"
#解压最终ZIP文件
unzip -o -q "${LOCAL_NAME}.zip"
done
#下载完成的后续操作
rm -f $REAL_DOWNLOAD_FILE
if [ -d "$INPUT_DIR/${LOCAL_NAME}-master" ];then
open "$INPUT_DIR/${LOCAL_NAME}-master"
fi
rm -f "${LOCAL_NAME}.zip"
