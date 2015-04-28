require "bunny"
require "emoji_data"
require "#{File.dirname(__FILE__)}/tweet_processor.rb"

include TweetProcessor

conn = Bunny.new(heartbeat: 10)
conn.start

ch   = conn.create_channel
q    = ch.queue("twitter", :durable => true)

ch.prefetch(1)
puts " [*] Waiting for messages. To exit press CTRL+C"

begin
  q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
    TweetProcessor.process_tweet(eval(body), "twitter")
    puts " [x] Done"
    ch.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  conn.close
end
