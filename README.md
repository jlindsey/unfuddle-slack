Unfuddle Slack Integration
==========================
Post ticket updates to Slack's webhook integration from your Unfuddle account.

Written in Ruby and optimized to run on Heroku, but could be run anywhere Ruby is installed.

Configuration
-------------
Since this was designed to be deployed on Heroku, configuration is done via environment variables. The
following variables are required:

  * `SLACK_URL`: The generated URL for your Slack incoming webhook
  * `UNFUDDLE_URL`: The URL for your Unfuddle account's activity feed endpoint
  * `UNFUDDLE_USER`: The username you want to use to authenticate with Unfuddle
  * `UNFUDDLE_PASS`: That user's password

Redis is also used to track which events have already been processed and sent to Slack. RedisCloud is the 
service I use for this on Heroku so the `REDISCLOUD_URL` env variable will be looked for. If it's not found, 
it defaults to `localhost:6379` for local development.

Running the script with the `--debug` argument will clear the Redis cache of remembered event IDs.

Running
-------
After ensuring the proper environment variables are set as outlined above (or using `dotenv` which is 
automatically loaded when running locally), you can simply run `ruby poll.rb` to start. You could also use 
Foreman, as a `Procfile` is included for Heroku. The script polls the Unfuddle activity feed every 10 seconds 
and posts any new events to the Slack webhook.

TODO
----
* Expose config options for polling interval
* Broaden support for Redis providers by checking for eg. `REDISTOGO_URL`
* Make the Unfuddle URL more dynamic by just setting an `UNFUDDLE_PROJECT_ID` var (for example)
* Tests!

License
-------
Copyright (c) 2015 Josh Lindsey. See [LICENSE](LICENSE) for details.

