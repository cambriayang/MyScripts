#!/usr/bin/ruby

# 处理Jenkins配置中的开关
# 传入参数：channel(appstore, adhoc, inhouse, push), debug_ring, show_flex, special_env, skip_jspatch_cer

@file = `find . -type f -name 'LuCommonConstants.h'`.split("\n").first
@jenkins_switches = ['DEBUG_RING', 'SHOW_FLEX', 'SPECIAL_ENV', 'SKIP_JSPATCH_CER']

def set_switch(switch_index, on)
  return if switch_index >= @jenkins_switches.count

  switch_name = @jenkins_switches[switch_index]
  match_string = "#define #{switch_name}"
  replace_string = on ? match_string : "\\/\\/#{match_string}"

  `sed -i '' 's/^.*#{match_string}.*$/#{replace_string}/g' #@file`
end

def bool_for(val)
  val =~ /^yes$/i ? true : false
end

def add_flex_pod
  file = `find . -type f -name 'Podfile'`.split("\n").first
  lines = File.readlines(file)

  pattern = /(?<=Debug\')(?=\])/
  replace_string = ", 'DailyBuild'"

  new_lines = lines.map do |line|
    line = line.sub(pattern, replace_string) if line =~ /FLEX/
    line
  end

  File.open(file, "w") do |f|
    new_lines.each {|line| f.puts line}
  end
end

if ARGV.count < 1
  puts "======> 请传入至少一个参数"
  exit 1
end

channel = ARGV[0]
ARGV.each_with_index do |value, index|
  next if index == 0

  # 当channel为appstore时，均关闭
  value = channel == "appstore" ? false : bool_for(value)

  # 当显示flex，则增加flex的pod
  if index == 2 && value
    add_flex_pod
  end

  set_switch(index-1, value)
end
