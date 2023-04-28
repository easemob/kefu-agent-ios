#!/bin/sh

echo -e "\033[31m================开始构建 清理缓冲=======================\033[0m"
rm -rf ./build_xcframework
rm -rf ./build_sdk_xcframework


echo -e '\033[31m================开始构建 agent  arm64 armv7=======================\033[0m'

#sed -i "" "s/HyphenateLite/Hyphenate/g" kefu-sdk-ios/helpdesk_sdk/helpdesk_sdk/HDMessage/HDMessage.h

xcodebuild  -workspace AgentSDKDemo.xcworkspace -scheme AgentSDK -configuration Release -sdk iphoneos BUILD_DIR="$(pwd)/build_sdk_xcframework/full" BUILD_ROOT="$(pwd)/build_sdk_xcframework/full" ARCHS="arm64 armv7" VALID_ARCHS="arm64 armv7"  CLANG_DEBUG_INFORMATION_LEVEL="line-tables-only" GCC_OPTIMIZATION_LEVEL=s GCC_GENERATE_DEBUGGING_SYMBOLS=YES clean build | xcpretty

echo -e '\033[31m================开始构建 HelpDesk  x86_64=======================\033[0m'
xcodebuild -workspace AgentSDKDemo.xcworkspace -scheme AgentSDK -configuration Release -sdk iphonesimulator BUILD_DIR="$(pwd)/build_sdk_xcframework/full" BUILD_ROOT="$(pwd)/build_sdk_xcframework/full" ARCHS="x86_64" VALID_ARCHS="x86_64" CLANG_DEBUG_INFORMATION_LEVEL="line-tables-only" GCC_OPTIMIZATION_LEVEL=s CODE_SIGNING_REQUIRED=NO clean build | xcpretty


echo -e '\033[31m================xcodebuild 完成 create  build_sdk_xcframework============\033[0m'

#mkdir build_sdk_xcframework

echo -e '\033[31m================xcodebuild  create  xcframework ============\033[0m'
#FULL版本
xcodebuild -create-xcframework \
-framework ./build_sdk_xcframework/full/Release-iphoneos/AgentSDK.framework  \
-framework ./build_sdk_xcframework/full/Release-iphonesimulator/AgentSDK.framework \
-output ./build_sdk_xcframework/sdk/AgentSDK.xcframework

echo -e '\033[31m==xcodebuild  create  xcframework 完成 打开build_xcframework 文件夹查看 打包情况 ============\033[0m'
open ./build_sdk_xcframework
