#!/usr/bin/ruby

require 'json'
require 'plist'

@configs = JSON.parse(File.read "./Configs/compiling_configs.json")
@channels = ['appstore', 'adhoc', 'inhouse', 'push']

def escaped_filename(file)
  file.gsub(' ', '\\ ')
end

def profile_name(file)
  file ? file.split("/").last.split(".").first : nil
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

def profile_names(channel)
  bundle_ids = @configs["common"]["bundle_ids"]
  bundle_ids.map {|bundle_id| profile_location channel, bundle_id }.map {|file| profile_name file }
end

def clean
  `xcodebuild clean -configuration "DailyBuild" | xcpretty 1>&2`
end

def archive(channel)
  return if not @channels.include?(channel)

  real_channel = channel == 'appstore' ? 'appstore' : 'adhoc'
  profile_keys = @configs["common"]["profiles"]
  profile_values = profile_names(real_channel)
  profile_string = profile_keys.count.times.map {|i| "#{profile_keys[i].upcase}='#{profile_values[i]}'"}.join(" ")

  archive_command = <<EOF
xcodebuild archive \
             -workspace "webApp.xcworkspace" \
             -scheme "webApp" \
             -configuration "DailyBuild" \
             -derivedDataPath "./build" \
             -archivePath "./build/Products/ljs-#{channel}.xcarchive" \
             CODE_SIGN_IDENTITY="#{@configs[real_channel]['code_sign_identity']}" \
             #{profile_string} \
           | xcpretty 1>&2
EOF

  puts "==============================>"
  puts "#{archive_command}"

  `#{archive_command}`
end

def generate_options_plist(channel)
  return if not @channels.include?(channel)

  real_channel = channel == 'appstore' ? 'appstore' : 'adhoc'
  dict = @configs[real_channel].select {|k, v| ['method', 'teamID', 'uploadSymbols', 'uploadBitcode'].include? k}

  dict["compileBitcode"] = false
  dict["signingStyle"] = "manual"
  dict["signingCertificate"] = @configs[real_channel]['code_sign_identity']

  bundle_ids = @configs["common"]["bundle_ids"]
  profile_names = profile_names(real_channel)
  dict["provisioningProfiles"] = bundle_ids.zip(profile_names).inject({}) {|hash, (bundle_id, profile_name)| hash[bundle_id] = profile_name; hash}

  File.open "./Configs/#{channel}.plist", "w" do |f|
    f.puts dict.to_plist
  end
end

def export(channel)
  return if not @channels.include?(channel)

  generate_options_plist(channel)

  export_command = <<EOF
sh ./Scripts/xcbuild-safe.sh -exportArchive \
             -archivePath "./build/Products/ljs-#{channel}.xcarchive" \
             -exportOptionsPlist "./Configs/#{channel}.plist" \
             -exportPath "./build/Products/#{channel}" 1>&2
EOF

  `#{export_command}`
end

def resign(channel)
  return if not @channels.include?(channel)

  # appstore, adhoc不需重签名，inhouse, push需要重签名
  return if ['appstore', 'adhoc'].include?(channel)

  bundle_ids = @configs["common"]["bundle_ids"]
  profile_locations = profile_locations(channel)

  temp_string = ""
  bundle_ids.count.times do |i|
    temp_string << "--provisioning_profile #{bundle_ids[i]}='#{profile_locations[i]}' "
  end

  resign_command = <<EOF
fastlane sigh resign #{temp_string} \
  --display_name "#{@configs[channel]['display_name']}" \
  --signing_identity "#{@configs[channel]['code_sign_identity']}" \
  "./build/Products/#{channel}/webApp.ipa" 1>&2
EOF

  puts "==============================>"
  puts "#{resign_command}"

  `#{resign_command}`
end

def move_files(channel)
  # copy ipa
  `cp ./build/Products/#{channel}/webApp.ipa ./build/Products/webApp.ipa`

  # zip dSYM
  `cd ./build/Products/ljs-#{channel}.xcarchive/dSYMs; zip -r lujinsuo.dSYM.zip lujinsuo.app.dSYM`
  `mv ./build/Products/ljs-#{channel}.xcarchive/dSYMs/lujinsuo.dSYM.zip ./build/Products/lujinsuo.dSYM.zip`
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

clean
archive(channel)
export(channel)
resign(channel)
move_files(channel)
