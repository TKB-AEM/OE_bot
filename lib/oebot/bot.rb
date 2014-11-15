# coding: utf-8

module OEbot
  class Bot

    attr_accessor \
      :config,
      :function, :name,
      :client, :timeline

    def initialize(debug:false, mention:false)
      @config = YAML.load_file('./config.yml')

      @function = OEbot::Function.new(@config['ReplayTable'], @config['buns_list'])
      @name = debug ? @config['name_debug'] : @config['name']

      oauth = debug ? 'oauth_debug' : 'oauth'
      @CONSUMER_KEY       = @config[oauth]['consumer_key']
      @CONSUMER_SECRET    = @config[oauth]['consumer_secret']
      @OAUTH_TOEKN        = @config[oauth]['oauth_token']
      @OAUTH_TOEKN_SECRET = @config[oauth]['oauth_token_secret']

      @client = Twitter::REST::Client.new do |c|
        c.consumer_key        = @CONSUMER_KEY
        c.consumer_secret     = @CONSUMER_SECRET
        c.access_token        = @OAUTH_TOEKN
        c.access_token_secret = @OAUTH_TOEKN_SECRET
      end

      if mention then
        TweetStream.configure do |c|
          c.consumer_key       = @CONSUMER_KEY
          c.consumer_secret    = @CONSUMER_SECRET
          c.oauth_token        = @OAUTH_TOEKN
          c.oauth_token_secret = @OAUTH_TOEKN_SECRET
          c.auth_method = :oauth
        end
        @timeline = TweetStream::Client.new
      end
    end


    # 通常の投稿
    def post(text = "", twitter_id:nil, status_id:nil, try:0)
      str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")

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
      error_logs("#{try}回目のpost", $!, $@)
      sleep 1
      retry if try < 3
    end


    # 140文字を超える投稿(分割投稿後140文字以下の最後の投稿を返す)
    def chain_post(text = "", twitter_id:nil, status_id:nil, try:0)
      over_text = text
      twitter_id_size = twitter_id ? ("@#{twitter_id}".size + 1) : 0

      # ↓”＠〜”と”str_time”19文字と”（続く）”4文字を除いた最終的にpostに返せる最大文字数で分割
      post_size = 140 - (twitter_id_size + 19 + 4)
      texts = over_text.scan(/.{1,#{post_size}}/m)

      begin
        0.upto(texts.size - 2) do |i|
          texts[i] = twitter_id ? "@#{twitter_id} #{texts[i]}(続く)" : "#{texts[i]}(続く)"
          @client.update(texts[i],{:in_reply_to_status_id => status_id})
          puts "#{texts[i]}\n\n"
        end
      rescue Twitter::Error
        try += 1
        error_logs("#{try}回目のchain_post", $!, $@)
        sleep 1
        retry if try < 3
      end

      str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")
      return "@#{twitter_id} #{texts[texts.size - 1]}\n#{str_time}"
    end


    # ふぁぼる
    def fav(status_id)
      if status_id
        @client.favorite(status_id)
      end
    rescue
      error_logs("fav", $!, $@)
    end

    # メンションじゃない投稿に反応
    def generate_response(contents, status_id, oebot)
      res_text = nil
      contents = contents.gsub(/@\w*/,"")
      contents = contents.gsub(/(\s|　)/,"")
      case contents
      when @function.rep_table['self'][0]
        oebot.fav(status_id)
        if contents.match(@function.rep_table['call'][0])
          res_text = @function.rep_table['call'][1].sample
        end
      end
      return res_text

    rescue
      error_logs("generate_response", $!, $@)
    end

    # メンションに反応
    def generate_reply(contents, twitter_id, oebot)
      contents = contents.gsub(/@\w*/,"")
      contents = contents.gsub(/(\s|　)/,"")
      rep_text = case contents
        when /(say|って言って|っていって)/i
          @function.say(contents)
        when /L棟(パン|ぱん)(ガチャ|がちゃ)?/
          @function.gacha
        when /(計算機室|機室|きしつ)/
          room = PCroom.new(2..91, timeout:5)
          "\n機室では#{room.count(:on)}台が稼働中です。"

        when /(誰か|だれか|誰が|だれが|おるか)/
          @function.being
        when /(記録|きろく)/
          @function.record(twitter_id)
        when /(退室|たいしつ|退出|たいしゅつ)/
          @function.rep_exit(oebot, twitter_id)

        when /(Ω|オーム)/
          @function.encode(contents)
        when /(黒|茶|赤|橙|黄|緑|青|紫|灰|白|金|銀)/
          @function.decode(contents)

        else # どのキーワードにも当てはまらなかったら
          @function.conversation(contents)
        end
      rep_text ||= @function.conversation(contents)
      return rep_text

    rescue
      error_logs("generate_reply", $!, $@)
    end
  end
end
