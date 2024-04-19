#!/bin/sh
# docker entrypoint script file for:
# - release
# - master

echo 'Begin Docker init script'
# avoid hard-coded usernames in entry script
myName=$(whoami)

echo ' - Checking container environment'
APP_PATH="/app"
# app path
chown -f $myName:$myName $APP_PATH
if ! [[ -w $APP_PATH ]]; then
    echo "FATAL: $APP_PATH is not writable"
    exit 1
fi
# volumes
if ! [[ -w $APP_PATH/soundboard && -w $APP_PATH/cert ]]; then
    echo 'NOTE: Trying to fix volumes permissions.'
    chown -Rf $myName:$myName $APP_PATH/soundboard \
                              $APP_PATH/cert
    if ! [[ -w $APP_PATH/soundboard && -w $APP_PATH/cert ]]; then
        echo 'FATAL: Volumes are not writable.'
        exit 1
    fi
    echo 'Done.'
fi

echo ' - Checking program files'
# bot files (only have to be readable)
if ! [[ -x $APP_PATH/yagpdb ]]; then
    echo 'NOTE: Trying to fix program files permissions.'
    # regardless of the owner, setting the mode to 0755 should allow current user to access the files
    chmod -f 0755 $APP_PATH/yagpdb
    if ! [[ -x $APP_PATH/yagpdb ]]; then
        echo 'FATAL: Program files are not executable'
        exit 1
    fi
    echo 'Done.'
fi

# put the -all fix here
echo 'All good'
yagBin="$APP_PATH/yagpdb"
if [[ $# -gt 0 ]]; then
    # CMD is not empty
    echo 'Reading CMD'
    if [[ "$1" == '/home/yagpdbbot/yagpdb' || "$1" == 'yagpdb' ]]; then
        # wrong path
        echo 'Wrong path corrected. Running yagpdb with CMD as parameters'
        # discard $1
        shift
        exec $yagBin "$@"
    elif ! [[ -f $1 ]]; then
        # $1 is not a regular file, assume it's yagpdb's parameter
        # if $1 exists but not executable... idk not my business?
        echo 'Running yagpdb with CMD as parameters'
        exec $yagBin "$@"
    else
        echo 'Running CMD'
        exec "$@"
    fi
else
    echo 'Running yagpdb -all'
    exec $yagBin -all
fi