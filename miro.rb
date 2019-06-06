require 'uri'
require 'net/http'
require "openssl"
require "json"
require_relative "config.rb"

# Define soa colors
UNCERTAIN_RED = "#f24726"
INCOMPLETE_ORANGE = "#fac710"
COMPLETE_GREEN = "#8fd14f"
SMALLBORDER_GREEN = "#0ca789"

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
def get_triage_frames()
  widgets_url = URI("https://api.miro.com/v1/boards/#{BOARD_ID}/widgets")
  result = send_get(widgets_url)
  widgets_collection = JSON.parse(result)
  # puts CIGREEN + "WIDGETS COLLECTION: " + CEND + "#{result}"
  widgets = widgets_collection["data"]
  tframes = Hash.new
  widgets.each do |widget|
    if is_triage_frame(widget)
      subtitle = get_tframe_subtitle(widget)
      puts CIGREEN + "TRIAGE FRAME FOUND with subtitle: " + CEND + "#{subtitle}"
      tframes[subtitle] = widget
    end
  end
  return tframes
end

# Returns widget hash (from JSON).
def get_widget_by_id(id)
  if id == nil
    raise 'Widget ID not found!'
  end
  widgets_url = URI("https://api.miro.com/v1/boards/#{BOARD_ID}/widgets/#{id}")
  result = send_get(widgets_url)
  widget = JSON.parse(result)
  puts CIGREEN + "GOT WIDGET: " + CEND + "#{result}"
  return widget
end

# Helper functions for requesting gets and posts
# I don't know if these are necessary or if there's a better way to do it —Will
def send_get(url)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)
  request["authorization"] = "Bearer #{ACCESS_TOKEN}"
  response = http.request(request)

  data = JSON.parse(response.read_body)
  if data["type"] == "error"
    status = data["status"]
    code = data["code"]
    message = data["message"]
    raise "Error #{status} #{code}: #{message}"
    return
  end

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

# returns the x,y coordinates of a given widget
def get_coordinates(widget)
  x = widget["x"]
  y = widget["y"]
  return x, y
end

# Creates a node with the given information
# * title thru user: self explanitory
# * issueID: the unique GitHub issue ID whic we can use to track the node
# * repo: the issue's repo. Decides which frame to create the node in.
def create_node(title, body, url, user, number, issueID, repo)
  widgets_url = URI("https://api.miro.com/v1/boards/#{BOARD_ID}/widgets")

  # compute location for card to appear based on repo
  # destination_frame = get_triage_frames()[repo]
  # look up location for card to appear based on repo
  destination_frame_id = FRAMES[repo]
  destination_frame = get_widget_by_id(destination_frame_id)

  x, y = get_coordinates(destination_frame)
  # compute scale for new node based on width of frame
  node_width = destination_frame["width"]*0.3
  node_height = node_width*0.7

  # add a little random nudge to the coordinates so nodes stack up visibly
  nudge_distance = 13.0
  x_nudge = rand(-nudge_distance..nudge_distance)
  y_nudge = rand(-nudge_distance..nudge_distance)
  node_x = x + x_nudge
  node_y = y + y_nudge

  # set up a hash of the information we want in our new node
  data = {
    "type"=>"shape",
    "text"=>"
    <p>#{title}
    <br><a href=\"#{url}\">\##{number}</a>
    <br>
    <br>#{body}
    <br>
    <br>opened by #{user}
    <br>~~ #{issueID}
    </p>",
    "style"=>{
      "backgroundColor"=>"UNCERTAIN_RED",
      "backgroundColor"=>"#f24726",
      "backgroundOpacity"=>1,
      "borderColor"=>"#f24726",
      "borderOpacity"=>1
    },
    "y"=>node_y,
    "x"=>node_x,
    "width"=>node_width,
    "height"=>node_height
  }
  # convert it to JSON
  json = data.to_json
  # send it to Miro
  result = send_post(widgets_url, json)
  puts CIGREEN + "CREATED NODE:" + CEND + result
end
