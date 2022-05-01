#!/usr/bin/ruby

def file_path(channel)
  `find ./build/Products -name 'ljs_#{channel}*.ipa'`.split("\n").first
end

def upload_for_appstore
  # 上传到TestFlight

  file_path = file_path('appstore')
  return if file_path == nil

  `fastlane pilot upload --ipa "#{file_path}"`
end

def upload_for_inhouse
  # 上传到蒲公英

  file_path = file_path('inhouse')
  return if file_path == nil

  u_key = "db91cd9ff1faaf9e499bbd50eb3e768e"
  api_key = "17ae78efad7c9dd960bf179df638b796"

  command = <<EOF
curl -F "file=@#{file_path}" \
-F "uKey=#{u_key}" \
-F "_api_key=#{api_key}" \
https://www.pgyer.com/apiv1/app/upload
EOF

  `#{command}`
end

if ARGV.count != 1
  puts "======> 请传入一个参数（appstore, inhouse）"
  exit 1
end

channel = ARGV[0]
if not ['appstore', 'inhouse'].include?(channel)
  puts "======> 请传入一个参数（appstore, inhouse）"
  exit 1
end

instance_eval("upload_for_#{channel}")
