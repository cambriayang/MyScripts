#!/usr/bin/env bash

channel=adhoc
BUILD_NUMBER=001
OpenDebugRing=YES
ShowFlex=YES
SpecialEnv=YES
SkipJSPatchCer=YES

echo "=====> 增加分支和Commit信息"
ruby ./Scripts/0_add_branch_and_commit_info.rb $channel $BUILD_NUMBER
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
# ruby ./Scripts/d_add_ijm_compile_flags.rb
echo "=====> 打包并导出"
ruby ./Scripts/e_archive_and_export.rb $channel
echo "=====> 重命名文件"
ruby ./Scripts/f_rename.rb $channel $BUILD_NUMBER
echo "=====> 只有adhoc包才会做：adhoc包重签名生成inhouse"
ruby ./Scripts/h_extra_resign_for_adhoc.rb $channel $BUILD_NUMBER
