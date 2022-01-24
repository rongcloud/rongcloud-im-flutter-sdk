#!bin/bash

help="clean.sh -m <mode>\nNotic: -m : debug or release"

while getopts ":m:" opt
do
    case $opt in
        m)
        mode=$OPTARG
        ;;
        ?)
        echo "$help"
        exit 1;;
    esac
done

if [[ -z $mode ]]; then
    echo "$help"
    exit 1
fi

cd $(dirname "$0")/.. && pwd;

flutter clean

# # 删除文件
if [[ $mode == "release" ]]; then

    rm example/ios/archive.plist
    rm -rf scripts
fi

rm -rf outputs

# # 删除敏感数据

if [[ $mode == "release" ]]; then
    mv -f example/lib/user_data_github.dart example/lib/user_data.dart
fi
