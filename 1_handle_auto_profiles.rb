#!/usr/bin/ruby

require 'json'
require 'plist'
require 'spaceship'

@configs = JSON.parse(File.read "./Configs/compiling_configs.json")

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
      "expiration_date" => expiration_date(profile),
      "has_provisioned_devices" => has_provisioned_devices(profile),
      "is_production" => is_production(profile)
    }
  end.select {|hash| hash["is_production"] }

def profile_names(channel, bundle_id)
  array = @profiles_info.select {|x| x["bundle_id"] == bundle_id }

  if channel == 'appstore'
    array = array.select {|x| x["has_provisioned_devices"] == false }
  elsif channel == 'adhoc'
    array = array.select {|x| x["has_provisioned_devices"] == true }
  end

  array.map {|hash| hash["profile_location"] }.map {|file| profile_name file }
end

def bundle_ids_for_channel(channel)
  bundle_ids = []

  if channel == "appstore" || channel == "adhoc"
    bundle_ids = @configs["common"]["bundle_ids"]
  else
    bundle_ids = @configs[channel]["new_bundle_ids"]
  end

  bundle_ids.map {|bundle_id| [channel, bundle_id] }
end

HOME = `echo $HOME`.strip
USERNAME = `cat ~/ios_scripts/spaceship_settings/USERNAME`.strip
PASSWORD = `cat ~/ios_scripts/spaceship_settings/PASSWORD`.strip

begin
  $client = Spaceship::Portal.login(USERNAME, PASSWORD)
rescue
  puts "==============================> Spaceship 登录失败"
  exit 0
end

if $client == nil
  puts "==============================> Spaceship 登录失败"
  exit 0
end

def select_team_id(channel)
  if channel == "inhouse"
    $client.team_id = 'A626DW584W'
  else
    $client.team_id = '8T9HE858RS'
  end
end

def remote_profiles(channel, bundle_id)
  select_team_id(channel)
  result = []

  if channel == "appstore"
    result = Spaceship::Portal.provisioning_profile.app_store.find_by_bundle_id(bundle_id).select {|x| x.devices.count == 0 }
  elsif channel == "adhoc"
    result = Spaceship::Portal.provisioning_profile.ad_hoc.find_by_bundle_id(bundle_id).select {|x| x.devices.count > 0 }
  elsif channel == "inhouse"
    result = Spaceship::Portal.provisioning_profile.in_house.find_by_bundle_id(bundle_id)
  elsif channel == "push"
    result = Spaceship::Portal.provisioning_profile.ad_hoc.find_by_bundle_id(bundle_id)
  end

  return result if result.count < 2

  expires_max = result.map(&:expires).max
  result.select {|x| x.expires >= expires_max }
end

def download_profile(profile)
  profile_location = "#{HOME}/Library/MobileDevice/Provisioning Profiles/#{profile.uuid}.mobileprovision"
  File.write(profile_location, profile.download)
end

def check_and_download(channel, bundle_id)
  local_names = profile_names(channel, bundle_id)
  remote_profiles(channel, bundle_id).each do |profile|
    if not local_names.include?(profile.uuid)
      puts "==============================> downloading #{profile.uuid}"
      download_profile(profile) 
    end
  end
end

def check_channel(channel)
  bundle_ids_for_channel(channel).each do |arr|
    check_and_download(arr[0], arr[1])
  end
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

if channel == "appstore"
  check_channel "appstore"
  check_channel "adhoc"
  check_channel "inhouse"
elsif channel == "adhoc" || channel == "inhouse"
  check_channel "adhoc"
  check_channel "inhouse"
elsif channel == "push"
  check_channel "adhoc"
  check_channel "push"
end
