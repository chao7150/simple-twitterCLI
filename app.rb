require "twitter"
require "thread"
require "./auth"
ENV["SSL_CERT_FILE"] = "ssl"

client_rest = Twitter::REST::Client.new do |config|
  config.consumer_key        = $CONSUMER_KEY
  config.consumer_secret     = $CONSUMER_SECRET
  config.access_token        = $OAUTH_TOKEN
  config.access_token_secret = $OAUTH_TOKEN_SECRET
end

client_stream = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = $CONSUMER_KEY
  config.consumer_secret     = $CONSUMER_SECRET
  config.access_token        = $OAUTH_TOKEN
  config.access_token_secret = $OAUTH_TOKEN_SECRET
end

tweets = []
number = 1
Thread.start do
  client_stream.user do |object|
    if object.is_a?(Twitter::Tweet)
      tweets << object
      puts '['+number.to_s+']'+object.user.screen_name
      puts  object.text
      puts
      number += 1
    end
  end
end

loop do
  args = gets.split()
  command = args.slice!(0)
  case command
  when 'tweet', 't'
    client_rest.update(args.join(' '))
    puts
  when 'fav', 'favorite'
    args.each do |id|
      client_rest.favorite(tweets[id.to_i - 1].id)
    end
    puts
  when 'rt', 'RT', 'r'
    args.each do |id|
      client_rest.retweet(tweets[id.to_i - 1].id)
    end
    puts
  when 'follow'
    args.each do |id|
      client_rest.follow(tweets[id.to_i - 1].user.id)
    end
    puts
  when 'exit', 'e'
    exit()
  puts
  end
end