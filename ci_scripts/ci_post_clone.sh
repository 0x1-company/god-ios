#!/bin/sh

script_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$script_dir/.."

echo $FILE_FIREBASE_DEVELOPMENT | base64 -D > App/Multiplatform/Development/GoogleService-Info.plist
echo $FILE_FIREBASE_STAGING | base64 -D > App/Multiplatform/Staging/GoogleService-Info.plist
echo $FILE_FIREBASE_PRODUCTION | base64 -D > App/Multiplatform/Production/GoogleService-Info.plist
