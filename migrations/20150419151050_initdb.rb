Sequel.migration do
  change do
    create_table :tweet_counts do
      Integer :total, :default => 0
    end

    create_table :tweet_hashtags do
      String :hashtag, :text => true
      index  :hashtag
    end

    create_table :tweet_urls do
      String :url, :text => true
      index  :url
    end

    create_table :tweet_times do
      Timestamp :time
      index     :time
    end

    create_table :tweet_emoji do
      String :emoji, :text => true
      index  :emoji
    end

    run 'INSERT INTO tweet_counts VALUES (0);'
  end
end
