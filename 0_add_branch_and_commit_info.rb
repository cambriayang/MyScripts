#!/usr/bin/ruby

# 往branch_commit.txt文件中增加Git信息

def add_info(channel, build_number, *branches)
  file = `find . -type f -name 'branch_commit.txt'`.strip

  # created_time
  created_time = `date`.strip
  `echo "created_time: #{created_time}" > #{file}`
  # channel
  `echo "channel: #{channel}" >> #{file}`
  # build_number
  `echo "build_number: #{build_number}" >> #{file}`
  # client_branch
  client_branch = branches[0] || `git branch | grep '\*'`.strip.sub(/^\*\s*/, '')
  `echo "client_branch: #{client_branch}" >> #{file}`
  # client_commit
  client_commit = `git rev-parse HEAD`.strip
  `echo "client_commit: #{client_commit}" >> #{file}`
  # h5_branch
  h5_branch = branches[1] || `cd ../html5-hybrid; git branch | grep '\*'`.strip.sub(/^\*\s*/, '')
  `echo "h5_branch: #{h5_branch}" >> #{file}`
  # h5_commit
  h5_commit = `cd ../html5-hybrid; git rev-parse HEAD`.strip
  `echo "h5_commit: #{h5_commit}" >> #{file}`
  # lumi_branch
  lumi_branch = branches[2] || `cd ../m-lumi-web; git branch | grep '\*'`.strip.sub(/^\*\s*/, '')
  `echo "lumi_branch: #{lumi_branch}" >> #{file}`
  # lumi_commit
  lumi_commit = `cd ../m-lumi-web; git rev-parse HEAD`.strip
  `echo "lumi_commit: #{lumi_commit}" >> #{file}`
end

if ARGV.count < 2
  puts "======> 请传入至少两个参数"
  puts "======> 第一个参数：channel（appstore, adhoc, inhouse, push）"
  puts "======> 第二个参数：build_number"
  puts "======> 其余参数： client分支 h5分支 lumi分支 casterModel分支"
  puts "======> 用法：ruby 0_add_branch_and_commit_info.rb appstore 168 DEV_3.6.7 DEV_3.6.7 master DEV_3.6.7"
  exit 1
end

channel = ARGV[0]
if not ['appstore', 'adhoc', 'inhouse', 'push'].include?(channel)
  puts "======> 请传入至少两个参数"
  puts "======> 第一个参数：channel（appstore, adhoc, inhouse, push）"
  puts "======> 第二个参数：build_number"
  puts "======> 其余参数： client分支 h5分支 lumi分支 casterModel分支"
  puts "======> 用法：ruby 0_add_branch_and_commit_info.rb appstore 168 DEV_3.6.7 DEV_3.6.7 master DEV_3.6.7"
  exit 1
end

add_info(*ARGV)
