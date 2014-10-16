# coding:utf-8

require 'yaml'
require 'twitter'
require 'tweetstream'

def logs(text)
  puts Time.now
  puts text
  puts ""
end

class Bot
  attr_accessor \
    :debug, :config,
    :rep_table,:name,
    :client, :timeline

  def initialize(debug:false,mention:false)

    @debug = debug
    @config = YAML.load_file('../lib/config.yml')

    @rep_table = @config['ReplayTable']
    @name = @debug ? @config['name_debug'] : @config['name']

    oauth = @debug ? 'oauth_debug' : 'oauth'
    @CONSUMER_KEY =       @config[oauth]['consumer_key']
    @CONSUMER_SECRET =    @config[oauth]['consumer_secret']
    @OAUTH_TOEKN =        @config[oauth]['oauth_token']
    @OAUTH_TOEKN_SECRET = @config[oauth]['oauth_token_secret']

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key =        @CONSUMER_KEY
      config.consumer_secret =     @CONSUMER_SECRET
      config.access_token =        @OAUTH_TOEKN
      config.access_token_secret = @OAUTH_TOEKN_SECRET
    end

    if mention then
      TweetStream.configure do |config|
        config.consumer_key =       @CONSUMER_KEY
        config.consumer_secret =    @CONSUMER_SECRET
        config.oauth_token =        @OAUTH_TOEKN
        config.oauth_token_secret = @OAUTH_TOEKN_SECRET
        config.auth_method = :oauth
      end
      @timeline = TweetStream::Client.new
    end
  end

  # 通常の投稿
  def post(text = "",twitter_id:nil,status_id:nil)
    str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")
    try = 0

      begin
        # 会話の返事
        if status_id
          rep_text = "@#{twitter_id} #{text}"
          rep_text += "\n#{str_time}"
          rep_text = self.chain_post(text,twitter_id:twitter_id,status_id:status_id) if rep_text.size > 140
          @client.update(rep_text,{:in_reply_to_status_id => status_id})
          puts "#{rep_text}\n\n"

        # ただの投稿(twitter_id:nil)か会話の始まり
        else
          post_text = twitter_id ? "@#{twitter_id} #{text}" : text
          post_text += "\n#{str_time}"
          post_text = self.chain_post(text,twitter_id:twitter_id,status_id:status_id) if post_text.size > 140
          @client.update(post_text)
          puts "#{post_text}\n\n"
        end

      # Twitter::Error::RequestTimeout: exection expired
      rescue Twitter::Error
        try += 1
        logs "#{try}回目のpost error #{$!.class}: #{$!}\n#{$@[0]}"
        sleep 1
        retry if try < 3
      end
  end


  # 140文字を超える投稿(分割投稿後140文字以下の最後の投稿を返す)
  def chain_post(text = "",twitter_id:nil,status_id:nil)
    over_text = text
    twitter_id_size = twitter_id ? ("@#{twitter_id}".size + 1) : 0

    # ↓”＠〜”と”str_time”19文字と”（続く）”4文字を除いた最終的にpostに返せる最大文字数で分割
    post_size = 140 - (twitter_id_size + 19 + 4)
    texts = over_text.scan(/.{1,#{post_size}}/m)
    try = 0

    begin
      0.upto(texts.size - 2) do |i|
        texts[i] = twitter_id ? "@#{twitter_id} #{texts[i]}(続く)" : "#{texts[i]}(続く)"
        @client.update(texts[i],{:in_reply_to_status_id => status_id})
        puts "#{texts[i]}\n\n"
      end
    rescue
      try += 1
      logs "#{try}回目のchain_post error #{$!.class}: #{$!}\n#{$@[0]}"
      sleep 1
      retry if try < 3
    end

    str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")
    return "@#{twitter_id} #{texts[texts.size - 1]}\n#{str_time}"
  end


  # ふぁぼる
  def fav(status_id:nil)
    if status_id
      @client.favorite(status_id)
    end

  rescue
    logs "fav error! #{$!.class}: #{$!}\n#{$@[0]}"
  end
end
