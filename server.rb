require 'tweetstream'
require 'bunny'

TweetStream.configure do |config|
  config.consumer_key       = '[YOUR_CONSUMER_KEY]'
  config.consumer_secret    = '[YOUR_CONSUMER_SECRET]'
  config.oauth_token        = '[YOUR_OAUTH_TOKEN]'
  config.oauth_token_secret = '[YOUR_OAUTH_TOKEN_SECRET]'
  config.auth_method        = :oauth
end

conn = Bunny.new(heartbeat: 10)
conn.start

queue_name = "twitter"
ch         = conn.create_channel
q          = ch.queue(queue_name, :durable => true)

TweetStream::Client.new.sample do |status|
  q.publish(status.to_hash.to_s, :persistent => true, :routing_key => q.name)
  puts "[x] Sent tweet: #{status.text}"
end

conn.close
