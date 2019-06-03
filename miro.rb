require 'uri'
require 'net/http'
require "openssl"
require "json"
require_relative "config.rb"

# Define colors
UNCERTAIN_RED = "#f24726"
INCOMPLETE_ORANGE = "#fac710"
COMPLETE_GREEN = "#8fd14f"
SMALLBORDER_GREEN = "#0ca789"

# Set up some urls
oauth_url = URI("https://api.miro.com/v1/oauth-token")

# Test whether a given widget is a triage frame
# * must start with "TRIAGE"
# * can have another term after it
def is_triage_frame(widget)
  return widget["type"] == "frame" && widget["title"] =~ /TRIAGE ?(.*)/
end

# returns the "subtitle" of the given triage frame. The subtitle is the words
# that come after "TRIAGE " in the frame's title.
def get_tframe_subtitle(widget)
  title = widget["title"]
  r = title.match(/TRIAGE ?(.*)/)
  return r[1]
end

# Looks through all widgets and returns the widgets that start with "TRIAGE"
# Returns a hash. Keys are the subtitles of the triage frames, values are the
# frame widgets themselves.
def find_triage_frames()
  widgets_url = URI("https://api.miro.com/v1/boards/#{BOARD_ID}/widgets")
  result = send_get(widgets_url)
  widgets_collection = JSON.parse(result)
  widgets = widgets_collection["data"]
  tframes = Hash.new
  widgets.each do |widget|
    if is_triage_frame(widget)
      subtitle = get_tframe_subtitle(widget)
      puts "TRIAGE FRAME FOUND with subtitle #{subtitle}"
      tframes[subtitle] = widget
    end
  end
  return tframes
end

# Helper functions for requesting gets and posts
#   I don't know if these are necessary or if there's a better way to do this
def send_get(url)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)
  request["authorization"] = "Bearer #{ACCESS_TOKEN}"
  response = http.request(request)
  return response.read_body
end

def send_post(url, body)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url)
  request["content-type"] = 'application/json'
  request["authorization"] = "Bearer #{ACCESS_TOKEN}"
  request.body = body
  response = http.request(request)
  return response.read_body
end

def get_coordinates(widget)
  x = widget["x"]
  y = widget["y"]
  return x, y
end

# Creates a node with the given information
# * title–user: self explanitory
# * issueID: the unique GitHub issue ID used to track the node
# * context: the scope that the issue relates to. Decided by SOMETHING from
#   GitHub information, manifests as the triage location the node is created in
def create_node(title, body, url, user, number, issueID, context)
  widgets_url = URI("https://api.miro.com/v1/boards/#{BOARD_ID}/widgets")

  # compute location for card to appear based on context
  x, y = get_coordinates(find_triage_frames()[context])

  data = {
    "type"=>"card",
    "title"=>"<p>#{title}<br><a href=\"#{url}\">\##{number}</a><br><br>#{body}<br><br>opened by #{user}<br>~~ #{issueID}",
    # {}"description"=>"test", # causes bug and gets lost on widget type change
    "style"=>{
      "backgroundColor"=>UNCERTAIN_RED # doesn't actually work how we want it b/c we're creating a card not a shape
    },
    "y"=>y,
    "x"=>x,
    "scale"=>1
  }
  json = data.to_json
  result = send_post(widgets_url, json)
  puts result
end
