#!/usr/bin/ruby

# 对于各个版本进行相应的修改

def modify_for_appstore
  # appstore版本所做的修改
end

def modify_for_adhoc
  # adhoc版本所做的修改
end

def modify_for_inhouse
  # inhouse版本所做的修改
end

def modify_for_push
  # push版本所做的修改
  # 修改GeTuiWrapper.m里参数的配置

  hash = {
    "startSdkWithAppId" => "2LgIbxmzYX7bWqTTeHBhyA",
    "appKey" => "7d7NK5KA2j5v0FurmWOiK7",
    "appSecret" => "Gzxd5MYyom7FemVcL6ygp8"
  }

  file = `find . -type f -name 'GeTuiWrapper.m'`.split("\n").first
  lines = File.readlines(file)

  new_lines = lines.map do |line|
    hash.each do |match_string, replace_string|
      line = replaced_whole_string(line, match_string, replace_string)
    end

    line
  end

  File.open(file, "w") do |f|
    new_lines.each {|line| f.puts line}
  end

  # 修改AppDelegate.m里bundle id的检查
  file = `find . -type f -name 'AppDelegate.m'`.split("\n").select {|x| x.include? "webApp"}.first
  `sed -i '' 's/^.*checkStop.*$//g' #{file}`
end

def replaced_whole_string(whole_string, match_string, replace_string)
  pattern = /(?<=#{match_string}:@\")\w+/
  whole_string.sub(pattern, replace_string)
end

if ARGV.count != 1
  puts "======> 请传入一个参数（appstore, adhoc, inhouse, push）"
  exit 1
end

channel = ARGV[0]
if not ['appstore', 'adhoc', 'inhouse', 'push'].include?(channel)
  puts "======> 请传入一个参数（appstore, adhoc, inhouse, push）"
  exit 1
end

instance_eval("modify_for_#{channel}")
