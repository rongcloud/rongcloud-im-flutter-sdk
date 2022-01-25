#!/bin/bash


cd $(dirname "$0") && pwd;

security unlock-keychain -p 5173rongcloud ~/Library/Keychains/login.keychain-db
security set-keychain-settings -t 3600 -l ~/Library/Keychains/login.keychain-db

sh release.sh -p "$PLATFORM" \
