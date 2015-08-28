#!/usr/bin/env ruby
require 'net/http'
require 'uri'
 
#
### Global Config
#
# httptimeout => Number in seconds for HTTP Timeout. Set to ruby default of 60 seconds.
# ping_count => Number of pings to perform for the ping method
#
httptimeout = 60
ping_count = 10

# 
# Check whether a server is Responding you can set a server to 
# check via http request or ping
#
# Server Options
#   name
#       => The name of the Server Status Tile to Update
#   url
#       => Either a website url or an IP address. Do not include https:// when using ping method.
#   method
#       => http
#       => ping
#
# Notes:
#   => If the server you're checking redirects (from http to https for example) 
#      the check will return false
#
servers = [
    {name: 'status-github', url: 'https://github.com/', method: 'http'},
    {name: 'status-pit', url: 'http://pit.afl.com.au', method: 'http'},
    {name: 'status-gvm', url: 'http://gvm.aflmedia.net/', method: 'http'},
    {name: 'status-jenkins', url: 'http://build.aflmedia.net/jenkins/login', method: 'http'},
    {name: 'status-nexus', url: 'http://build.aflmedia.net/nexus/index.html', method: 'http'},
]
 
SCHEDULER.every '2m', :first_in => 0 do |job|
    servers.each do |server|
        if server[:method] == 'http'
            begin
                uri = URI.parse(server[:url])
                http = Net::HTTP.new(uri.host, uri.port)
                http.read_timeout = httptimeout
                if uri.scheme == "https"
                    http.use_ssl=true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                end
                request = Net::HTTP::Get.new(uri.to_s)
                response = http.request(request)

                puts "[DEBUG] Checking #{uri.to_s} server response code: #{response.code}"
                if response.code == "200" || response.code == "302"
                    result = 1
                else
                    result = 0
                end
            rescue Timeout::Error
                result = 0
            rescue Errno::ETIMEDOUT
                result = 0
            rescue Errno::EHOSTUNREACH
                result = 0
            rescue Errno::ECONNREFUSED
                result = 0
            rescue SocketError => e
                result = 0
            end
        elsif server[:method] == 'ping'
            result = `ping -q -c #{ping_count} #{server[:url]}`
            exitStatus = $?.exitstatus
            puts "[DEBUG] Pinging #{url}: #{exitStatus}"
            if exitstatus == 0
                result = 1
            else
                result = 0
            end
        end

        send_event(server[:name], result: result)
    end
end