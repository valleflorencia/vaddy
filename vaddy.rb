require 'net/http'
require 'uri'
require 'json'
require './vaddy_libs.rb'

API_SERVER = 'https://api.vaddy.net';

vaddy_token = ARGV[0] != nil ? ARGV[0] : ENV["VADDY_TOKEN"];
vaddy_user  = ARGV[1] != nil ? ARGV[1] : ENV["VADDY_USER"];
vaddy_host  = ARGV[2] != nil ? ARGV[2] : ENV["VADDY_HOST"];

if( vaddy_token == nil || vaddy_user == nil || vaddy_host == nil) then
  puts "ERROR: need more argument or env."
  puts "USAGE: ruby vaddy.rb auth_key username host"
  puts "or set env VADDY_TOKEN, VADDY_USER and VADDY_HOST"
  exit(1)
end

base_info = {
  "auth_key" => vaddy_token,
  "user"     => vaddy_user,
  "fqdn"     => vaddy_host,
}


# start scan
start_query_hash = base_info
start_query_hash["action"] = "start"
start_url = API_SERVER + "/v1/scan"
scan_id = start_scan(start_url, start_query_hash)

if( scan_id == nil )
  puts "ERROR: Can not get scan_id"
  exit(1)
end

sleep(5)

# check status
check_query_hash = base_info
check_query_hash["scan_id"] = scan_id

query_string = build_query(check_query_hash)
check_request_url = API_SERVER + "/v1/scan/result?" + query_string
status = vaddy_check( check_request_url )
exit(status)



