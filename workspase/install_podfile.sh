#!/bin/sh

#  BuildFramework.sh
#  CocoapodsDemo
#
#  Created by zhengfeng on 17/2/10.
#  Copyright © 2017年 zhengfeng. All rights reserved.


cd `dirname $0`

frameworkfile="Build-framework.feng"

outputfile="podfile"

APP_NAME="CocoapodsDemo"

cat << EOF >> ${outputfile}

post_install do |installer|
    names = Array.new
        installer.pods_project.targets.each do |target|
        if !(target.name == "Pods-"+"$APP_NAME")
            framework_name = target.name.slice(5,target.name.length)
            names<<framework_name
        end
    end
    puts names
    File.open("$frameworkfile", "w") do |aFile|
        content=""
        names.each do |name|
            content += name+"\n"
        end
        content[content.length - 1] = ""
        aFile.syswrite(content)
    end
end
EOF
