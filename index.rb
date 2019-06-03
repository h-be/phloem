require 'sinatra'
require 'json'
require_relative 'miro.rb'
require_relative 'colors.rb'

# Set custom port
set :port, 8089

# React to an incoming webhook payload
post '/payload/issues' do
  json = request.body.read
  push = JSON.parse(json)
  # puts "\e[38;5;196mI got some JSON: \e[0m \n#{push.inspect}\n\n"
  # puts "#{json.inspect}"

  # assign names to relevant data from the JSON payload recieved
  action = push["action"] # whether the issue was opened, closed, or reopened
  # the issue section inside the push is where most of the data we want is
  issue = push["issue"]
  title = issue["title"]
  body = issue["body"]
  url = issue["html_url"]
  number = issue["number"] # The number that's seen and reference on GitHub.com
  issueID = issue["id"] # GitHub unique ID for the issue
  user = push["sender"]["login"]
  # get repo from issue JSON so we know which frame to put the new node in
  repo = push["repository"]["name"]

  puts CIGREEN + "The action is: " + CEND + action
  puts CIGREEN + "The title is: " + CEND + title
  puts CIGREEN + "The body is: " + CEND + body
  puts CIGREEN + "The url is: " + CEND + url
  puts CIGREEN + "The repo is:" + CEND + repo

  # Do things based on what the update was
  case action
  when "opened"
    puts CGREEN + "OPENED!" + CEND

    puts "creating node with the following information: title=#{title},
    body=#{body}, url=#{url}, user=#{user}, number=#{number} issueID=#{issueID}"
    puts "putting this node in the following triage frame: #{repo}"

    create_node(title, body, url, user, number, issueID, repo)

  when "closed"
    puts CGREEN + "CLOSED!" + CEND
    # turn color to green
  when "reopened"
    puts CGREEN + "REOPENED!" + CEND
    # turn color back to something
  else
    puts "Action was #{action} and the translator doesn't know what to
    do about that"
  end
end
