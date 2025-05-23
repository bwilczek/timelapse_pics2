require 'dropbox_api'
require 'fileutils'
require 'json'

file = ARGV[0]
SRC_ROOT = "/home/ftp/upload/"
DEST_ROOT = "/home/greta/TIMELAPSE_PICS"
DEST_OWNER = "greta"

raise "File argument missing" unless file
# raise "File #{file} does not exist" unless File.exist?(file)

puts "Processing file: #{file}"

stripped_file = file.sub(/^#{SRC_ROOT}/, "")

puts "Stripped path: #{stripped_file}"

device, day, _subfolder, _format, hour, basename = stripped_file.split("/")

puts "Device: #{device}"
puts "Day: #{day}"
puts "Hour: #{hour}"
puts "Base name: #{basename}"

DEVICE_MAP = {
  '8D0A0DFPAG1E848' => 'Ogrod1',
  '8D0A0DFPAGAD681' => 'Ogrod2',
  '8D0A0DFPAG377E0' => 'Bok',
  '7L065A6PAG6FF25' => 'Ulica'
}

cam_name = DEVICE_MAP.fetch(device)
puts "Camera name: #{cam_name}"

dest_path = "#{DEST_ROOT}/#{cam_name}/#{day}.jpg"
puts "Dest path: #{dest_path}"

if File.exist?(dest_path)
  puts "File #{dest_path} already exists, skipping."
  exit 0
end

puts "Copy #{file} to #{dest_path}"

puts "Uploading to dropbox..."

CLIENT_ID = ENV.fetch('DROPBOX_TIMELAPSEPICS_APP_KEY')
CLIENT_SECRET = ENV.fetch('DROPBOX_TIMELAPSEPICS_APP_SECRET')

authenticator = DropboxApi::Authenticator.new(CLIENT_ID, CLIENT_SECRET)

token_hash = JSON.parse(File.read('tmp/dropbox.token'))
access_token = OAuth2::AccessToken.from_hash(authenticator, token_hash)

client = DropboxApi::Client.new(
  access_token: access_token,
  on_token_refreshed: lambda { |new_token_hash| File.open('tmp/dropbox.token', "w") { |f| f.write(JSON.pretty_generate(new_token_hash)) } }
)
begin
  client.upload "/Test/Gemfile", File.read('Gemfile')
rescue => e
  puts "Error: #{e.message}"
  exit 1
end
