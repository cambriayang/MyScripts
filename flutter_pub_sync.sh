#!/bin/bash
GREEN='\033[36m'
BLUE='\033[34m'
RED='\033[31m'
YELLOW_COLOR='\033[33m'
END='\033[0m'

currentDir=`pwd`

startUpProjectFold='HBFlutterCommonDebugProject'
debugProjectFold='hb_flutter_common_debug_libs'

function syncAll() {
  flutter pub get
  flutter pub upgrade

  cd $debugProjectFold
  flutter pub get
  flutter pub upgrade
  cd -

  cd $startUpProjectFold
  flutter pub get
  flutter pub upgrade
  cd -

  echo -e "$YELLOW_COLOR pub update finish $END"
}

syncAll

echo -e "$YELLOW_COLOR pub update finish $END"

exit