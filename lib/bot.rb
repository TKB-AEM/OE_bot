# coding:utf-8

require 'yaml'
require 'twitter'
require 'tweetstream'
require_relative "./card.rb"
require_relative "./function/function.rb"

class Bot
  attr_accessor :client, :timeline, :keys, :function

  def initialize(reply = false)

    @keys = YAML.load_file('../list/config.yml')
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = @keys["consumer_key"]
      config.consumer_secret = @keys["consumer_secret"]
      config.access_token = @keys["oauth_token"]
      config.access_token_secret = @keys["oauth_token_secret"]
    end

    @function = Function.new()

    if reply then
      TweetStream.configure do |config|
        config.consumer_key = @keys["consumer_key"]
        config.consumer_secret = @keys["consumer_secret"]
        config.oauth_token = @keys["oauth_token"]
        config.oauth_token_secret = @keys["oauth_token_secret"]
        config.auth_method = :oauth
      end
      @timeline = TweetStream::Client.new
    end

  end

  def post(text,username,id = nil,debug = false)

    # debugモードでは実際にPostしない
    if debug
      if id
        rep_text = "@#{username} #{text}"
        puts "#{rep_text}\n\n"
      else
        puts "#{text}\n\n"
      end

    else
      if id
        rep_text = "@#{username} #{text}"
        @client.update(rep_text,{:in_reply_to_status_id => id})
        puts "#{rep_text}\n\n"
      else
        @client.update(text)
        puts "#{text}\n\n"
      end
    end

  rescue => em
    puts "post error #{em}"
  end

  def fav(id = nil)
    if id
      @client.favorite(id)
    end

  rescue => em
    puts "fav error #{em}"
  end

end
