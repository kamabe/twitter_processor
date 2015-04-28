require "#{File.dirname(__FILE__)}/database.rb"

module TweetReport
  include DB

  def report(database)
    @conn = DB.get_postgres_connection(database)
    top_emoji_in_tweets
    space
    percent_tweets_with_emoji
    space
    top_hashtags
    space
    percent_tweets_with_url
    space
    percent_tweets_with_photo_url
    space
    top_domains
    space
    avg_tweets_per_hour
    space
    avg_tweets_per_minute
    space
    avg_tweets_per_second
    space
    total_tweets
    @conn.close
  end

  def space
    puts "\n\n"
  end

  def top_emoji_in_tweets
    puts "** Top Emoji in Tweets **"
    sql = "SELECT emoji, count(*) AS total FROM tweet_emoji GROUP BY emoji ORDER BY total DESC LIMIT 5"
    @conn.exec(sql).each do |row|
      puts "#{row['emoji']}: #{row['total']}"
    end
  end

  def percent_tweets_with_emoji
    puts "** % Tweets with Emoji **"
    sql =<<-SQL
      SELECT (count(*)::numeric / (SELECT total FROM tweet_counts LIMIT 1)::numeric) * 100 AS percent
      FROM tweet_emoji
    SQL

    @conn.exec(sql).each do |row|
      puts "#{row['percent'].to_f.round(2)}%"
    end
  end

  def top_hashtags
    puts "** Top Hashtags in Tweets **"
    sql = "SELECT hashtag, count(*) AS total FROM tweet_hashtags GROUP BY hashtag ORDER BY total DESC LIMIT 5"
    @conn.exec(sql).each do |row|
      puts "#{row['hashtag']}: #{row['total']}"
    end
  end

  def percent_tweets_with_url
    puts "** % Tweets with URL **"
    sql =<<-SQL
      SELECT (count(*)::numeric / (SELECT total FROM tweet_counts LIMIT 1)::numeric) * 100 AS percent
      FROM tweet_urls
    SQL

    @conn.exec(sql).each do |row|
      puts "#{row['percent'].to_f.round(2)}%"
    end
  end

  def percent_tweets_with_photo_url
    puts "** % Tweets with Photo URL **"
    sql =<<-SQL
      SELECT (count(*)::numeric / (SELECT total FROM tweet_counts LIMIT 1)::numeric) * 100 AS percent
      FROM tweet_urls
      WHERE url LIKE '%instagram%' OR url LIKE '%pic.twitter.com%'
    SQL

    @conn.exec(sql).each do |row|
      puts "#{row['percent'].to_f.round(2)}%"
    end
  end

  def top_domains
    puts "** Top Domains in Tweets **"
    sql =<<-SQL
      WITH domains AS (
        SELECT (regexp_split_to_array(url, '/'))[3] AS domain
        FROM tweet_urls
      )
      SELECT domain, count(*) AS total
      FROM domains
      GROUP BY domain
      ORDER BY total DESC
      LIMIT 5
    SQL
    @conn.exec(sql).each do |row|
      puts "#{row['domain']}: #{row['total']}"
    end
  end

  def total_tweets
    puts "** Total Tweets **"
    sql = "SELECT total FROM tweet_counts LIMIT 1"
    @conn.exec(sql).each do |row|
      puts "Total: #{row['total']}"
    end
  end

  def avg_tweets_per_hour
    puts "** Average Tweets per Hour **"
    sql =<<-SQL
      SELECT avg(total) AS average
      FROM (
        SELECT date_trunc('hour', time) AS hour, count(*) AS total
        FROM tweet_times
        GROUP BY date_trunc('hour', time)
        ORDER BY date_trunc('hour', time)
      ) x
    SQL

    @conn.exec(sql).each do |row|
      puts "#{row['average'].to_f.round(0)}"
    end
  end

  def avg_tweets_per_minute
    puts "** Average Tweets per Minute **"
    sql =<<-SQL
      SELECT avg(total) AS average
      FROM (
        SELECT date_trunc('minute', time) AS minute, count(*) AS total
        FROM tweet_times
        GROUP BY date_trunc('minute', time)
        ORDER BY date_trunc('minute', time)
      ) x
    SQL

    @conn.exec(sql).each do |row|
      puts "#{row['average'].to_f.round(0)}"
    end
  end

  def avg_tweets_per_second
    puts "** Average Tweets per Second **"
    sql =<<-SQL
      SELECT avg(total) AS average
      FROM (
        SELECT date_trunc('second', time) AS second, count(*) AS total
        FROM tweet_times
        GROUP BY date_trunc('second', time)
        ORDER BY date_trunc('second', time)
      ) x
    SQL

    @conn.exec(sql).each do |row|
      puts "#{row['average'].to_f.round(0)}"
    end
  end
end
