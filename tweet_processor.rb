require "#{File.dirname(__FILE__)}/database.rb"

module TweetProcessor
  include DB

  def process_tweet(tweet, database)
    @conn = DB.get_postgres_connection(database)

    sql = increment_num_tweets() +
          process_time(tweet) +
          process_emoji(tweet) +
          process_hashtags(tweet) +
          process_urls(tweet)

    @conn.transaction { |t| t.exec(sql) }
    @conn.close
  end

  def increment_num_tweets
    "UPDATE tweet_counts SET total = total + 1;"
  end

  def process_time(tweet)
    "INSERT INTO tweet_times (time) VALUES ('#{tweet[:created_at]}'::timestamp);"
  end

  def process_emoji(tweet)
    sql   = ""
    emoji = EmojiData.scan(tweet[:text]).map { |m| "('#{m.name}')" }

    if emoji.size > 0
      sql = "INSERT INTO tweet_emoji (emoji) VALUES #{emoji.join(',')};"
    end

    sql
  end

  def process_hashtags(tweet)
    sql      = ""
    hashtags = tweet[:entities][:hashtags].map { |hashtag| "('#{hashtag[:text]}')" }.join(',')

    if hashtags.size > 0
      sql =<<-SQL
        INSERT INTO tweet_hashtags (hashtag) VALUES #{hashtags};
      SQL
    end

    sql
  end

  # Escape url because some of them are weird
  def process_urls(tweet)
    sql  = ""
    urls = tweet[:entities][:urls].map { |url| "('#{@conn.escape_string(url[:expanded_url])}')" }.join(',')

    if urls.size > 0
      sql =<<-SQL
        INSERT INTO tweet_urls (url)
        VALUES #{urls};
      SQL
    end

    sql
  end
end
