# translator
> Translates between git issues and SoA nodes

# Background
translator listens for new issues created in a GitHub repo and creates corresponding leaf nodes in a triage area (frame?).

# Install

## Dependencies

* ruby
* [Sinatra](http://sinatrarb.com/)
* [ngrok](https://ngrok.com/)


1. #### **Set up ngrok** (for development)
    1. Start ngrok on port 8089: `ngrok http 8089` or `./ngrok http 8089`
2. #### **Connect to GitHub**
   1. [Create a webhook](https://developer.github.com/webhooks/creating/) in the GitHub repo.
   2. Enter your ngrok url `payload/issues` appended as the Payload URL: `http://********.ngrok.io/payload/issues`
   3. Set the content type to "application/json"
   4. During setup, under "Which events would you like to trigger this webhook?", select "Issues". Make sure to deselect "Pushes".
   5. Save the webhook
   6. *Create a webhook with these settings in each repo you want to link to the Miro board.*
3. #### **Connect to Miro**
   1. Go to Miro > [Your organization] > Settings > Profile settings > Your apps [Beta].
   2. Add a new app and note the Client id and secret.
   3. Select the following scopes:
       * `boards:read`
       * `boards:write`
       * `boards_content:read`
       * `boards_content:write`
   4. Click "Install app and get OAuth Token" and follow the instructions.
   5. Note the [access token](https://developers.miro.com/reference#authorization-and-authentication) Miro gives you.
   6. Make a config file called `config.rb` with the following consts defined. A sample config file ([sample_config.rb](/sample_config.rb)) is provided to copy and edit.
      * `CLIENT_ID` -  Found in "manage apps" settings in Miro
      * `CLIENT_SECRET` - Found in "manage apps" settings in Miro
      * `ACCESS_TOKEN` - API access token from Miro
      * `BOARD_ID` - ID of Miro board
      * `FRAMES` - Defines which repos link to which frames. Each key-value pair consists of a repo name and the Miro Widget ID of the frame that issues from that repo should appear inside. To find the Widget ID of a frame, right-click on it in Miro and select "Copy link". The link will look like `https﻿://miro.com/app/board/i9E_keXrQeL=/?moveToWidget=2238459382770409338`. The number at the end, `2238459382770409338`, is the Widget ID.

  [comment]: # (Watch out!, there's a non-breaking zero-width space character in the URL in the last line of the code block above, between the 's' and ':')

4. #### **Set up Miro board**
   1. For each connected GitHub repo, create a frame and title it `TRIAGE` followed by the name of the repo. For example, the triage frame for this repo would be titled: `TRIAGE translator`.
   2. *Done! New issues should now appear in the triage frame corresponding to their repo! You can move the frames anywhere on the board.*

# Usage
Run the server with `ruby index.rb`. When an issue is created you should see output.

For development, stop and restart the Sinatra server when you make changes. Make sure to stop the server once you're done or it'll keep running "headless."
