require 'sinatra'
require 'json'

# Set custom port
set :port, 8089

# React to an incoming webhook payload
post '/payload/issues' do
  json = request.body.read
  push = JSON.parse(json)
  # puts "\e[38;5;196mI got some JSON: \e[0m \n#{push.inspect}\n\n"
  # puts "#{json.inspect}"

  action = push["action"]

  issue = push["issue"]
  title = issue["title"]
  body = issue["body"]
  url = issue["html_url"]
  issueID = issue["id"]

  user = push["sender"]["login"]
  # state = issue["state"]

  puts "\e[38;5;196mThe action is:\e[0m #{action}"
  puts "\e[38;5;196mThe title is:\e[0m #{title}"
  puts "\e[38;5;196mThe body is:\e[0m #{body}"
  puts "\e[38;5;196mThe url is:\e[0m #{url}"

  # Do things based on what the update
  case action
  when "opened"
    puts "OPENED!"
    # Create a node
    # title
    # body
    # url as link
    # opened by: user
    # issueID
  when "closed"
    puts "CLOSED!"
    # turn color to green
  when "reopened"
    puts "REOPENED!"
    # turn color back to something
  else
    puts "Action was #{action} and the translator doesn't know what to
    do about that"
  end

end

post '/payload/projects' do
  json = request.body.read
  # push = JSON.parse(json)
  # puts "#{json.inspect}"

end
