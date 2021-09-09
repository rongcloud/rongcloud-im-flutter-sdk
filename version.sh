#!/bin/bash

version=$(awk -F '[= #]' '{a=1}a==1&&$1~/version:/{print $2;exit}' pubspec.yaml)

awk "{
        gsub(/static final String sdkVersion = .*/, \"static final String sdkVersion = \\\"$version\\\";\");
        print;
    }" lib/src/rong_im_client.dart > .tmp && mv .tmp lib/src/rong_im_client.dart
