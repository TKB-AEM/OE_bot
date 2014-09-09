# coding:utf-8

require 'yaml'
require 'twitter'
require 'tweetstream'

class Bot
  attr_accessor :client, :timeline

  def initialize(reply:false)

    keys = YAML.load_file('../list/config.yml')
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = keys["consumer_key"]
      config.consumer_secret = keys["consumer_secret"]
      config.access_token = keys["oauth_token"]
      config.access_token_secret = keys["oauth_token_secret"]
    end

    if reply then
      TweetStream.configure do |config|
        config.consumer_key = keys["consumer_key"]
        config.consumer_secret = keys["consumer_secret"]
        config.oauth_token = keys["oauth_token"]
        config.oauth_token_secret = keys["oauth_token_secret"]
        config.auth_method = :oauth
      end
      @timeline = TweetStream::Client.new
    end

  end

  def post(text = "",twitter_id:nil,status_id:nil,debug:false)

    # debugモードでは実際にPostしない
    if debug
      if status_id
        rep_text = "@#{twitter_id} #{text}"
        puts "#{rep_text}\n\n"
      else
        puts "#{text}\n\n"
      end

    else
      if status_id
        rep_text = "@#{twitter_id} #{text}"
        @client.update(rep_text,{:in_reply_to_status_id => status_id})
        puts "#{rep_text}\n\n"
      else
        @client.update(text)
        puts "#{text}\n\n"
      end
    end

  rescue => em
    puts "post error #{em}"
  end

  def fav(status_id:nil)
    if status_id
      @client.favorite(status_id)
    end

  rescue => em
    puts "fav error #{em}"
  end

end
