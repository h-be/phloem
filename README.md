# translator
> Translates between git issues and SoA nodes

# Background
translator listens for new issues created in a GitHub repo and creates corresponding leaf nodes in a Mirro State of Affairs tree under a "Triage" root node.

# Install

## Dependencies
* ruby
* [sinatra](http://sinatrarb.com/)
* [ngrok](https://ngrok.com/)

1. Start ngrok on port 8089: `ngrok http 8089` or `./ngrok http 8089`
2. [Create a webhook](https://developer.github.com/webhooks/creating/) on the GitHub repo you'll be interfacing with.
3. Enter your ngrok url `payload/issues` appended as the Payload URL: `http://********.ngrok.io/payload/issues`
4. During setup, under "Which events would you like to trigger this webhook?", select "Issues".
5. Save the webhook

# Usage
Run the server with `ruby index.rb`. When an issue is created you should see output.
