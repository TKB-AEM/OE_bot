# coding:utf-8

require 'yaml'
require 'twitter'
require 'tweetstream'

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

  # 通常の投稿(rep_text→リプライ text→リプライでない)
  def post(text = "",twitter_id:nil,status_id:nil)
    str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")

    # リプライ
    if status_id
      rep_text = "@#{twitter_id} #{text}"
      rep_text += "\n#{str_time}"
      rep_text = self.chain_post(text,twitter_id:twitter_id,status_id:status_id) if rep_text.size > 140
      @client.update(rep_text,{:in_reply_to_status_id => status_id})
      puts "#{rep_text}\n\n"

    # リプライでない（リプライでない投稿で140字を超える内容はない）
    else
      text = "@#{twitter_id} #{text}" if twitter_id
      text += "\n#{str_time}"
      @client.update(text)
      puts "#{text}\n\n"
    end

  rescue => em
    puts Time.now
    puts "post error #{em}"
  end


  # 140文字を超える投稿(分割投稿後140文字以下の最後の投稿を返す)
  def chain_post(text = "",twitter_id:nil,status_id:nil)
    over_text = text
    twitter_id_num = "@#{twitter_id}".size + 1

    # ↓”＠〜”と”str_time”19文字と”（続く）”4文字を除いた最終的にpostに返せる最大文字数で分割
    post_num = 140 - (twitter_id_num + 19 + 4)
    rep_texts = over_text.scan(/.{1,#{post_num}}/m)

    0.upto(rep_texts.size - 2) do |i|
      rep_texts[i] = "@#{twitter_id} #{rep_texts[i]}(続く)"
      @client.update(rep_texts[i],{:in_reply_to_status_id => status_id})
      puts "#{rep_texts[i]}\n\n"
    end

    str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")
    return "@#{twitter_id} #{rep_texts[rep_texts.size - 1]}\n#{str_time}"

  rescue => em
    puts Time.now
    puts "post2 error #{em}"
  end


  # ふぁぼる
  def fav(status_id:nil)
    if status_id
      @client.favorite(status_id)
    end

  rescue => em
    puts Time.now
    puts "fav error #{em}"
  end

end
