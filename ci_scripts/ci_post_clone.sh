#!/bin/zsh

script_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$script_dir/.."

echo $FILE_FIREBASE_STAGING | base64 --decode > App/Multiplatform/Staging/GoogleService-Info.plist
echo $FILE_FIREBASE_PRODUCTION | base64 --decode > App/Multiplatform/Production/GoogleService-Info.plist
