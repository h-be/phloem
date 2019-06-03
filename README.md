# translator
> Translates between git issues and SoA nodes

# Background
translator listens for new issues created in a GitHub repo and creates corresponding leaf nodes in a triage area (frame?).

# Install

## Dependencies

* ruby
* [Sinatra](http://sinatrarb.com/)
* [ngrok](https://ngrok.com/)


1. **Set up ngrok** (for development)
    1. Start ngrok on port 8089: `ngrok http 8089` or `./ngrok http 8089`
2. **Connect to GitHub**
   1. [Create a webhook](https://developer.github.com/webhooks/creating/) on the GitHub repo you'll be interfacing with.
   2. Enter your ngrok url `payload/issues` appended as the Payload URL: `http://********.ngrok.io/payload/issues`
   3. During setup, under "Which events would you like to trigger this webhook?", select "Issues".
   4. Save the webhook
3. **Connect to Miro**
   1. Get an [API key](https://developers.miro.com/reference#authorization-and-authentication) from Miro:
   2. Go to Miro > [Your organization] > Settings > Profile settings > Your apps [Beta].
   3. Add a new app and note the Client id and secret.
   4. Select the following scopes:
       * `boards:read`
       * `boards:write`
       * `boards_content:read`
       * `boards_content:write`
   5. Click "Install app and get OAuth Token"
   4. Make a file called `config.rb` with the following consts defined:
      ```
      * CLIENT_ID = '[client id]'  # Must be replaced from "manage apps" settings
      * CLIENT_SECRET = '[client secret]'  # Must be replaced from "manage apps" settings
      * API_KEY = "[API key]"
      * BOARD_ID = "[Miro board id]"  # Found in board URL: https://miro.com/app/board/[board id]/
      ```

# Usage
Run the server with `ruby index.rb`. When an issue is created you should see output.

For development, stop and restart the Sinatra server when you make changes. Make sure to stop the server once you're done or it'll keep running "headless."
