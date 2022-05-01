#!/usr/bin/ruby

require 'json'
require 'xcodeproj'

@configs = JSON.parse(File.read "./Configs/compiling_configs.json")

def add_flags_to_target(target_name, flags)
  path = `find . -type d -name '#{target_name}.xcodeproj'`.split("\n").first
  return if path == nil

  project = Xcodeproj::Project.open(path)
  target = project.targets.select {|x| x.name == target_name}.first
  return if target == nil

  target.build_configurations.each do |config|
    config.build_settings['OTHER_CFLAGS'] = flags
  end

  project.save()
  STDOUT.puts("=====> IJM: #{target_name} has added flags")
end

targets = @configs['common']['ijm_targets']
flags = @configs['common']['ijm_other_cflags']

targets.each do |target|
  add_flags_to_target(target, flags)
end
