#!/usr/bin/ruby

def rename(channel, build_number)
  `mv ./build/Products/webApp.ipa ./build/Products/ljs_#{channel}_#{build_number}.ipa`
  `mv ./build/Products/lujinsuo.dSYM.zip ./build/Products/ljs_#{channel}_#{build_number}.dSYM.zip`
end

if ARGV.count != 2
  puts "======> 请传入两个参数"
  puts "======> 第一个参数：channel（appstore, adhoc, inhouse, push）"
  puts "======> 第二个参数：build_number"
  puts "======> 用法：ruby f_rename.rb appstore 168"
  exit 1
end

channel = ARGV[0]
if not ['appstore', 'adhoc', 'inhouse', 'push'].include?(channel)
  puts "======> 请传入两个参数"
  puts "======> 第一个参数：channel（appstore, adhoc, inhouse, push）"
  puts "======> 第二个参数：build_number"
  puts "======> 用法：ruby f_rename.rb appstore 168"
  exit 1
end

build_number = ARGV[1]
rename(channel, build_number)
