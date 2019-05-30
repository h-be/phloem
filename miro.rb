require 'uri'
require 'net/http'
require "openssl"
require "json"
require_relative "config.rb"

UNCERTAIN_RED = "#f24726"
NEW_NODE_LOCATION = [10,-15]

oauth_url = URI("https://api.miro.com/v1/oauth-token")

def send_get(url)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)
  request["authorization"] = "Bearer #{API_KEY}"
  response = http.request(request)
  return response.read_body
end

def send_post(url, body)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url)
  request["content-type"] = 'application/json'
  request["authorization"] = "Bearer #{API_KEY}"
  request.body = body
  response = http.request(request)
  return response.read_body
end

def create_node(title, body, url, user, number, issueID)
  widgets_url = URI("https://api.miro.com/v1/boards/#{BOARD_ID}/widgets")
  data = {
    "type"=>"card",
    "title"=>"<p>#{title}<br><a href=\"#{url}\">\##{number}</a><br><br>#{body}<br><br>opened by #{user}<br>~~ #{issueID}",
    # {}"description"=>"test", # causes bug and gets lost on widget type change
    "style"=>{
      "backgroundColor"=>UNCERTAIN_RED
    },
    "y"=>NEW_NODE_LOCATION[0],
    "x"=>NEW_NODE_LOCATION[1],
    "scale"=>0.49687972316570445
  }
  json = data.to_json
  result = send_post(widgets_url, json)
  puts result
end
