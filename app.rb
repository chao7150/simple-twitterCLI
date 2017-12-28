require "twitter"
require "thread"
require "oauth"

ENV["SSL_CERT_FILE"] = "ssl"

$CONSUMER_KEY       = '41fEYpctnCXzxUsuYR9jlnY9q'
$CONSUMER_SECRET    = 'LXSy878XkbJjx5z3lC9RTQBel68p8kaWAGdG3QfadlGZwgI4sN'

if !File.exist?('auth.rb') then
  puts "login process starts"
  consumer_key = $CONSUMER_KEY
  consumer_secret = $CONSUMER_SECRET
  consumer = OAuth::Consumer.new consumer_key, consumer_secret, site: "https://api.twitter.com"

  request_token = consumer.get_request_token

  puts "Please visit here: #{request_token.authorize_url}"
  STDERR.print "Then input your PIN: "

  access_token = request_token.get_access_token oauth_verifier: gets.chomp
  $OAUTH_TOKEN = access_token.token
  $OAUTH_TOKEN_SECRET = access_token.secret
  File.open('auth.rb', 'w') do |text|
    text.puts('$OAUTH_TOKEN = ' + '"' + $OAUTH_TOKEN + '"')
    text.puts('$OAUTH_TOKEN_SECRET = ' + '"' + $OAUTH_TOKEN_SECRET + '"')
  end
  else
  require "./auth"
end


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

puts 'input "h" to read help'

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
  when 'help', 'h'
    puts 'This is help.'
    puts 'Basic syntax: command + arg'
    puts '---commands---'
    puts '"tweet" or "t" to tweet.          arg:tweet content without quotations'
    puts '"fav" or "favorite" to favorite.  arg:tweet number(s)'
    puts '"rt", "RT" or "r" to retweet.     arg:tweet number(s)'
    #puts '"follow" to follow.               arg:tweet number(s)'
    puts '"exit" or "e" to exit.            arg:not required'
    puts
  when 'exit', 'e'
    exit()
  puts
  end
end