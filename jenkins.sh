#!/usr/bin/env bash

set -e
set -o pipefail

export LC_ALL="zh_CN.UTF-8"
export LANG="zh_CN.UTF-8"
export PATH=/usr/local/bin:$PATH:/usr/local/sbin:/usr/bin

alias lnpm="cnpm 
--registry=http://registry.npm.lu-fe.com \
--registryweb=http://npm.lu-fe.com \
--cache=~/.npm/.cache/lnpm"

alias cnpm="npm 
--registry=https://registry.npm.taobao.org \
--cache=$HOME/.npm/.cache/cnpm \
--disturl=https://npm.taobao.org/dist \
--userconfig=$HOME/.cnpmrc"

echo "=====> 当前的Hybrid分支是：$hybrid"
echo "=====> 当前的Native分支是：$client"
echo "=====> 当前的Lumi分支是：$lumi"

#第一次打包cp node_modules文件到h5目录
cd ${WORKSPACE}/html5-hybrid/html5-framework
if [ ! -d "node_modules" ]; then
  echo "=====> 开始拷贝老框架打包的npm资源包"
  cp -r /Users/ljs/Documents/IOS_Docs/node_modules/html5-framework/node_modules .     
fi

cd ${WORKSPACE}/mobile-client
rm -rf ./build

security unlock-keychain -p 'LJSmobile' ~/Library/Keychains/login.keychain

echo "=====> 增加分支和Commit信息"
ruby ./Scripts/0_add_branch_and_commit_info.rb $channel $BUILD_NUMBER $client $hybrid $lumi $CasterModel
echo "=====> 处理Jenkins配置开关（channel: $channel, OpenDebugRing: $OpenDebugRing, ShowFlex: $ShowFlex, SpecialEnv: $SpecialEnv, SkipJSPatchCer: $SkipJSPatchCer ）"
ruby ./Scripts/a_handle_jenkins_switches.rb $channel $OpenDebugRing $ShowFlex $SpecialEnv $SkipJSPatchCer

pod update

echo "=====> 删除老版本ReactiveCocoa的报错"
ruby ./Scripts/1_remove_reactivecocoa_warning.rb
echo "=====> 修改配置文件"
ruby ./Scripts/b_modify_config_files.rb $channel
echo "=====> 修改Code Signing为Manual"
ruby ./Scripts/c_make_signing_manual.rb
echo "=====> 爱加密增加编译参数"
ruby ./Scripts/d_add_ijm_compile_flags.rb
echo "=====> 打包并导出"
ruby ./Scripts/e_archive_and_export.rb $channel
echo "=====> 重命名文件"
ruby ./Scripts/f_rename.rb $channel $BUILD_NUMBER
echo "=====> 只有adhoc包才会做：adhoc包重签名生成inhouse"
ruby ./Scripts/h_extra_resign_for_adhoc.rb $channel $BUILD_NUMBER
