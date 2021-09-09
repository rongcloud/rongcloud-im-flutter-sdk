#!/bin/bash
# shellcheck disable=SC2012,SC2103,SC2035,SC2046

help="release.sh \
-p <platform>"

while getopts ":s:h:" opt
do
    case $opt in
        p)
        platform=$OPTARG
        ;;
        h)
        echo "$help"
        exit 1;;
        ?)
        echo "$help"
        exit 1;;
    esac
done

if [ -z "$platform" ]; then
  echo "$help"
  exit 1
fi

if [ ! -d "outputs" ]; then
  mkdir outputs
else
  rm -rf outputs
  mkdir outputs
fi

sh version.sh

flutter clean
flutter pub get
cd example || exit
flutter clean
name="flutter-im-demo"

if [ "$platform" == "android" ]; then
  flutter build apk --release
  current=$(date "+%Y-%m-%d-%H-%M-%S")
  cp -rf build/app/outputs/flutter-apk/app-release.apk ../outputs/"$name"-android-"$current".apk || exit 1
  end="apk"
elif [ "$platform" == "ios" ]; then
  rm -rf DerivedData
  flutter pub get

  cd ios
  /Library/Ruby/Gems/2.6.0/gems/cocoapods-1.10.1/bin/pod update
  /Library/Ruby/Gems/2.6.0/gems/cocoapods-1.10.1/bin/pod install
  # pod update
  # pod install

  xcodebuild archive \
             -workspace "./Runner.xcworkspace" \
             -scheme "Runner" \
             -archivePath "../build/Runner.xcarchive" \
             -configuration "Release" \
             -sdk iphoneos \
             APP_PROFILE="" \
             SHARE_PROFILE="" \
             -allowProvisioningUpdates
             
  xcodebuild -exportArchive \
             -archivePath "../build/Runner.xcarchive" \
             -exportOptionsPlist "archive.plist" \
             -exportPath "../build" \
             -allowProvisioningUpdates
  current=$(date "+%Y-%m-%d-%H-%M-%S")
  mv ../build/RC_Flutter_Demo.ipa ../../outputs/${name}-ios-"$current".ipa || exit 1
  cd ..
  end="ipa"
fi

cd ../outputs
rm -rf $(ls -t *.$end | tail -n +6)


