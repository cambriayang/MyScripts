#!/usr/bin/env bash
#
# Author: xiesy
# CreateDate: 2017-11-01
#
# Description:
#   change the build version for the Info.plist files in a batch.
#
#
#
#

change_version() {
    # /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' webApp/webApp-Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString \"$2\"" "$1"
}

check_exec_dir() {
    current_dir=$(pwd)
    for target in "${TARGET_DIR_NAMES[@]}" ; do
        echo "${current_dir}/$1"
        if [[ ! -d "${current_dir}/$1" ]] ; then
            exit 1
        fi
    done
    exit 0
}

usage() {
cat <<__EOF

Description
    Change the build version for every target \`Info.plist\` file in a batch.
    Targets are pre-defined in this script. You can set your own targets as you like.

Usage
    Scripts/change-versions.sh <target_version>
__EOF
}


declare -a TARGET_DIR_NAMES=('TodayExtension' 'webApp' 'NotificationServiceExtension')

if [[ "$1" == '-h' ]] ; then
    usage
    exit 0
fi

if [[ ! $(check_exec_dir) ]] ; then
    echo '>>>[Error] This script should be executed under the project root directory.'
    exit $?
fi

for target in "${TARGET_DIR_NAMES[@]}" ; do
    for plist in "$target"/*Info.plist ; do
        change_version "$plist" "$1"
    done
done
