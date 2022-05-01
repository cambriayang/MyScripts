#!/usr/bin/ruby

# 2017-8-24
# 虽然名字是 extra_resign_for_adhoc， 但现在
# appstore 会重签出 adhoc, inhouse
# adhoc 会重签出 inhouse

require 'json'
require 'plist'

@configs = JSON.parse(File.read "./Configs/compiling_configs.json")

def escaped_filename(file)
  file.gsub(' ', '\\ ')
end

def provisioning_profiles
  return `find ~/Library/MobileDevice/Provisioning\\ Profiles -type f -name '*.mobileprovision'`.split("\n").map(&:strip)
end

def bundle_id(file)
  string = `security cms -D -i #{escaped_filename file} | grep -A1 application-identifier | tail -1`.strip
  return string.match(/(?<=\.)[^<]*(?=<)/)[0]
end

def creation_date(file)
  string = `security cms -D -i #{escaped_filename file} | grep -A1 CreationDate | tail -1`.strip
  return string.match(/(?<=\>)[^<]*(?=<)/)[0]
end

def expiration_date(file)
  string = `security cms -D -i #{escaped_filename file} | grep -A1 ExpirationDate | tail -1`.strip
  return string.match(/(?<=\>)[^T]*(?=T)/)[0]
end

def has_provisioned_devices(file)
  string = `security cms -D -i #{escaped_filename file} | grep ProvisionedDevices`.strip
  string =~ /ProvisionedDevices/ ? true : false
end

def is_production(file)
  `security cms -D -i #{escaped_filename file} > /tmp/temp.plist`
  Plist.parse_xml("/tmp/temp.plist")['DeveloperCertificates'].count == 1
end

@profiles_info = provisioning_profiles.map do |profile|
    {
      "profile_location" => profile,
      "bundle_id" => bundle_id(profile),
      "creation_date" => creation_date(profile),
      "expiration_date" => expiration_date(profile),
      "has_provisioned_devices" => has_provisioned_devices(profile),
      "is_production" => is_production(profile)
    }
  end.select {|hash| hash["is_production"] }

def profile_location(channel, bundle_id)
  array = @profiles_info.select {|x| x["bundle_id"] == bundle_id }

  if channel == 'appstore'
    array = array.select {|x| x["has_provisioned_devices"] == false }
  elsif channel == 'adhoc'
    array = array.select {|x| x["has_provisioned_devices"] == true }
  end

  hash = array.sort {|x, y| "#{x["expiration_date"]} #{x["creation_date"]}" <=> "#{y["expiration_date"]} #{y["creation_date"]}" }.last
  hash ? hash["profile_location"] : nil
end

def profile_locations(channel)
  bundle_ids = @configs[channel]["new_bundle_ids"]
  bundle_ids.map {|new_bundle_id| profile_location channel, new_bundle_id }
end

def extra_resign_for(channel, real_channel, build_number)
  `cp ./build/Products/ljs_#{channel}_#{build_number}.ipa ./build/Products/ljs_#{real_channel}_#{build_number}.ipa`

  bundle_ids = @configs["common"]["bundle_ids"]
  profile_locations = profile_locations(real_channel)

  temp_string = ""
  bundle_ids.count.times do |i|
    temp_string << "--provisioning_profile #{bundle_ids[i]}='#{profile_locations[i]}' "
  end

  resign_command = <<EOF
fastlane sigh resign #{temp_string} \
  --display_name "#{@configs[real_channel]['display_name']}" \
  --signing_identity "#{@configs[real_channel]['code_sign_identity']}" \
  "./build/Products/ljs_#{real_channel}_#{build_number}.ipa" 1>&2
EOF

  puts "==============================>"
  puts "#{resign_command}"

  `#{resign_command}`
end

def extra_resign(channel, build_number)
  if channel == "appstore"
    extra_resign_for(channel, "adhoc", build_number)
    extra_resign_for(channel, "inhouse", build_number)
  elsif channel == "adhoc"
    extra_resign_for(channel, "inhouse", build_number)
  end
end

if ARGV.count != 2
  puts "======> 请传入两个参数"
  puts "======> 第一个参数：channel（appstore, adhoc, inhouse, push）"
  puts "======> 第二个参数：build_number"
  puts "======> 用法：ruby h_extra_resign_for_adhoc.rb adhoc 168"
  exit 1
end

channel = ARGV[0]
if not ['appstore', 'adhoc', 'inhouse', 'push'].include?(channel)
  puts "======> 请传入两个参数"
  puts "======> 第一个参数：channel（appstore, adhoc, inhouse, push）"
  puts "======> 第二个参数：build_number"
  puts "======> 用法：ruby h_extra_resign_for_adhoc.rb adhoc 168"
  exit 1
end

build_number = ARGV[1]
extra_resign(channel, build_number)
