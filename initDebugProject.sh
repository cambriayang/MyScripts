#!/bin/bash
$clear
echo -e '\n\n\n\n\n'

GREEN='\033[36m'
BLUE='\033[34m'
RED='\033[31m'
YELLOW_COLOR='\033[33m'
END='\033[0m'

currProjectName=$(grep  "name: " pubspec.yaml | cut -d ":" -f 2)
currentDir=`pwd`

startUpProjectPath="https://gitlab.hellobike.cn/MopedApp/HBFlutterCommonDebugProject.git"
startUpProjectFold='HBFlutterCommonDebugProject'
startUpProjectBranch="yang_ns"

function addDependenceConfig() {
    cd $startUpProjectFold
    writerDependenceConfig $currProjectName $currentDir
    cd -
}
function writerDependenceConfig() {
  grep $1 pubspec.yaml > /dev/null
#  if [ $? -ne 0 ]; then
    echo -e "$YELLOW_COLOR 开始配置调试工程Yaml文件 $END"
    line=$(grep -n "dependency_overrides:"  pubspec.yaml | head -1 | cut -d ":" -f 1)

    echo "dependency_overrides：$line"
    dependenciesLine=$line
    insertNameLine=`expr $line + 1`
    insertPathIndex=`expr $line + 2`

    local blank2="  "
    sed -i '' "$dependenciesLine a\\
$1:
     " pubspec.yaml
    sed -i '' ''"${insertNameLine}"'s/^/'"${blank2}"'/' pubspec.yaml

    local blank4="    "
    sed -i '' "$insertNameLine a\\
path: ../.
    " pubspec.yaml
    sed -i '' ''"${insertPathIndex}"'s/^/'"${blank4}"'/' pubspec.yaml
#  fi
}

function loadAndroidYmal() {
  echo "loadAndroidYmal"
  while [ 0 -eq 0 ]; do
    read -t 30 -p "是否需要拉去Android YMAL文件（y/n）:" isLoadAndroidYmal
    if [[ $isLoadAndroidYmal == 'y' || $isLoadAndroidYmal == 'Y' ]];then
      read -t 30 -p "请输入dep tag（默认master）:" androidDepTag
      cd $debugProjectFold > /dev/null
      cd android > /dev/null
      if [ "$androidDepTag" != "" ];then
        ./gradlew prepareDep --tag $androidDepTag > /dev/null
      else
        ./gradlew prepareDep
      fi
      break
    else
      if [[ $isLoadAndroidYmal == 'n' || $isLoadAndroidYmal == 'N' ]]; then
        break
      else
        echo -e "输入错误！！"
        continue
      fi
    fi
  done

  cd $currentDir > /dev/null
}

function loadIOSYmal() {
  echo "loadIOSYmal"
  while [ 0 -eq 0 ]; do
    read -t 30 -p "是否需要拉去IOS YMAL文件（y/n）:" isLoadIOSYmal
    if [[ $isLoadIOSYmal == 'y' || $isLoadIOSYmal == 'Y' ]];then
      cd "$debugProjectFold/ios"
        read -t 30 -p "请输入dep tag（默认master）:" iosDepTag
        cd $debugProjectFold > /dev/null
        cd ios > /dev/null
        if [ "$iosDepTag" != "" ];then
          echo "loadIOSYmal"
        else
          ./gradlew prepareDep
        fi
      break
    else
      if [[ $isLoadIOSYmal == 'n' || $isLoadIOSYmal == 'N' ]]; then
        break
      else
        echo -e "输入错误！！"
        continue
      fi
    fi
  done
  cd $currentDir > /dev/null
}

function cloneProject() {
  cd $currentDir

  if [ ! -d $1 ]; then
    echo "start git debug project from:: $2"
    git clone $2
  else
    echo -e "$RED Debugging project directory already exists ！！！ $END"
  fi

  cd $1
  git checkout $3 > /dev/null
  if [ $? -eq 0 ]; then
      echo -e "$BLUE 切换分支至: $3 $END"
  else
    echo -e "$RED 切换分支失败，会从master分支检出目标分支:$3 $END"
    git checkout -B $3 > /dev/null
  fi

  git pull > /dev/null

  cd -
}

function addGitignore() {
  echo -e "$YELLOW_COLOR 打印当前路径： $currentDir $END"
  echo -e "$YELLOW_COLOR 打印startUpProjectFold： $startUpProjectFold $END"

  grep $startUpProjectFold .gitignore > /dev/null
  if [ $? -ne 0 ]; then
    echo -e "$YELLOW_COLOR 开始添加 gitignore $END"
    sed -i '' '1i\
    '${startUpProjectFold}/'
    '  .gitignore
  else
    echo -e "$YELLOW_COLOR gitignore 已经添加 $END"
  fi
}

function syncAll() {
  flutter pub get
  flutter pub upgrade

  cd $startUpProjectFold
  flutter pub get
  flutter pub upgrade
  cd -

  echo -e "$YELLOW_COLOR pub update finish $END"
}

echo -e "$GREEN ****************************************** $END"
echo -e "$GREEN ** 欢迎来到两轮Flutter $END"
echo -e "$GREEN ** 工程: $currProjectName $END"
echo -e "$GREEN ** Solver: tiankeyu04630@hellobike.com $END"
echo -e "$GREEN ** 开始初始化... "
echo -e "$GREEN ****************************************** $END\n\n"


read -p "请输入分支:" startUpProjectBranch
if  [ ! -n "$startUpProjectBranch" ] ;then
    echo "没有输入分支，会默认master分支"
    startUpProjectBranch="yang_ns"
else
    echo "输入的分支为: $startUpProjectBranch"
fi

echo "当前路径: $currentDir"
echo -e "$YELLOW_COLOR Start Clone Project $END"
cloneProject $startUpProjectFold $startUpProjectPath $startUpProjectBranch
addGitignore
addDependenceConfig
syncAll

#loadAndroidYmal
#loadIOSYmal

echo -e '\n\n'
echo -e "$BLUE 初始化完成！！！ $END"
echo -e "$BLUE 请运行$debugProjectFold 工程的main.dart $END"
echo -e '\n\n'
exit
