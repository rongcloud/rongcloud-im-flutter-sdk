#!/bin/bash
# shellcheck disable=SC2046,SC2164

help="github.sh -b <branch> -m <message>\nNotic:You need to make sure that you have already commit all your work in your current branch before you run this script.\nAnd if you don't want to commit and push the changes automatically, you can just leave the message field empty."

while getopts ":b:m:h:" opt
do
    case $opt in
        b)
        branch=$OPTARG
        ;;
        m)
        message=$OPTARG
        ;;
        h)
        echo "$help"
        exit 1;;
        ?)
        echo "$help"
        exit 1;;
    esac
done

if [ -z "$branch" ]; then
  echo "$help"
  exit 1
fi

cd $(dirname "$0")/.. && pwd;

status=$(git status)
clean_EN="nothing to commit, working tree clean"
clean_CH="无文件要提交，干净的工作区"
if [[ $status =~ $clean_EN ]] || [[ $status =~ $clean_CH ]]; then
  git checkout "$branch"
  git merge --allow-unrelated-histories --squash --strategy-option=theirs dev
  sh scripts/clean.sh -m "release"
  
#  if [ -n "$message" ]; then
#    git commit -am "\"$message\""
#    git push
#  fi
else
  echo "$status"
  echo "You need to commit your current work first!"
  exit 1
fi