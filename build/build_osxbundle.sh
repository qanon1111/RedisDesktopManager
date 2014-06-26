#!/bin/sh
QTPATH=/Users/admin/Qt/5.3/clang_64/bin
export PATH=$PATH:$QTPATH

SOURCE_DIR=`pwd`

echo ===========================
TAG=$1
echo Version: $TAG
echo ===========================

rm -fR ./bin/linux/release/*

echo '============== Build crash reporter ================'
cd ./3rdparty/crashreporter
qmake CONFIG+=release DESTDIR=$SOURCE_DIR/bin/linux/release DEFINES+=RDM_VERSION="\\\"$1\\\""
make -s clean
make -s -j 2

echo '============== Build rdm ================'
cd ./../../src/
pwd

echo ===========================
echo replace tag in Info.plist:
cp resources/Info.plist.sample resources/Info.plist
sed -i “s/0.0.0/$TAG/g” resources/Info.plist
echo ===========================

sh ./configure
qmake
make -s clean
make -s -j 2

echo ‘============== Create release bundle ================’
cd ./../

BUNDLE_PATH=./bin/linux/release/ 
BUILD_DIR=$BUNDLE_PATH/rdm.app/Contents/
MAC_TOOL=$QTPATH/macdeployqt

cp -f ./src/resources/Info.plist $BUILD_DIR/
cp -f ./src/resources/rdm.icns $BUILD_DIR/Resources/

cd $BUNDLE_PATH

$MAC_TOOL rdm.app -dmg -executable=./rdm.app/Contents/MacOS/crashreporter
cp rdm.dmg redis-desktop-manager-$TAG.dmg