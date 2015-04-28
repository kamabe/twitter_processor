require "#{File.dirname(__FILE__)}/tweet_report.rb"

include TweetReport

while true
  begin
    TweetReport.report('twitter')
    sleep(10)
  rescue Exception => e
    puts e
    sleep(10)
  end
end
