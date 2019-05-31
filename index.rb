require 'sinatra'
require 'json'
require_relative 'miro.rb'

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
  number = issue["number"]
  issueID = issue["id"]

  user = push["sender"]["login"]
  # state = issue["state"]

  puts "\e[32;3mThe action is:\e[0m #{action}"
  puts "\e[32;3mThe title is:\e[0m #{title}"
  puts "\e[32;3mThe body is:\e[0m #{body}"
  puts "\e[32;3mThe url is:\e[0m #{url}"

  # Do things based on what the update was
  case action
  when "opened"
    puts "OPENED!"
    puts "creating node with the following information: title=#{title},
    body=#{body}, url=#{url}, user=#{user}, number=#{number} issueID=#{issueID}"
    create_node(title, body, url, user, number, issueID, "network") # FIXME #
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
