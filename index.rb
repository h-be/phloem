require 'sinatra'
require 'json'
require_relative 'miro.rb'
require_relative 'colors.rb'

# Set bind address (network interface)
set :bind, defined?(PHLOEM_BIND) ? PHLOEM_BIND : 'localhost' 
# Set port
set :port, defined?(PHLOEM_PORT) ? PHLOEM_PORT : 8089 

# React to an incoming webhook payload
post '/payload/issues' do
  json = request.body.read
  payload = JSON.parse(json)
  # puts "\e[38;5;196mI got some JSON: \e[0m \n#{payload.inspect}\n\n"
  # puts "#{json.inspect}"

  # the issue section inside the payload is where most of the data we want is
  issue = payload["issue"]

  if issue == nil
    puts CIGREEN + "This payload isn't an issue! You probably have an additional event selected by accident in your GitHub webhook settings. Or maybe you just added a new webhook." + CEND
    return
  end

  # assign names to relevant data from the JSON payload recieved
  action = payload["action"] # whether the issue was opened, closed, or reopened
  title = issue["title"]
  body = issue["body"]
  url = issue["html_url"]
  number = issue["number"] # The number that's seen and reference on GitHub.com
  issueID = issue["id"] # GitHub unique ID for the issue
  user = payload["sender"]["login"]
  # get repo from issue JSON so we know which frame to put the new node in
  repo = payload["repository"]["name"]

  puts CIGREEN + "The action is: " + CEND + action
  puts CIGREEN + "The title is: " + CEND + title
  puts CIGREEN + "The body is: " + CEND + body
  puts CIGREEN + "The url is: " + CEND + url
  puts CIGREEN + "The repo is: " + CEND + repo

  # Do things based on what the update was
  case action
  when "opened"
    puts CGREEN + "OPENED!" + CEND

    create_node(title, body, url, user, number, issueID, repo)

  when "closed"
    puts CGREEN + "CLOSED!" + CEND
    # turn color to green
  when "reopened"
    puts CGREEN + "REOPENED!" + CEND
    # turn color back to something
  else
    puts "Action was #{action} and the phloem doesn't know what to
    do about that"
  end
end
