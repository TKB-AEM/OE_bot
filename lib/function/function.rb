#coding:utf-8

require_relative "./esysPinger.rb"
require_relative "./gacha.rb"
require_relative "./color_code.rb"
require_relative "./talk.rb"
require_relative "../database/database.rb"
require_relative "../database/time_to_str.rb"

$okaeri = ["okaeri1.wav","okaeri2.wav","okaeri3.wav","okaeri4.wav"]

class Bot
  class Function

    attr_accessor :data

    def initialize
      @data = Database.new()
    end

    def Function::generate_reply(contents,username,debug)
      function = new
      str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")

      if contents =~ /(おーいー|oe|OE|openesys|OpenEsys|open_esys|Open_Esys)(_||\s)(BOT|Bot|bot|ボット|ﾎﾞｯﾄ|ぼっと)/ then
        return function.call(str_time)

      elsif contents =~ /(誰か|だれか|誰が|だれが|おるか)/ then
        return function.being(str_time)

      elsif contents =~ /(ping|Ping|PING)/ then
        return function.ping(str_time)

      elsif contents =~ /(計算機室|機室|きしつ)/ then
        return function.esys_pinger(str_time)

      elsif contents =~ /L棟(パン|ぱん)(ガチャ|がちゃ)/ then
        return function.ltou_gacha(str_time)

      elsif contents =~ /(Ω|オーム)/ then
        return function.color_encode(contents)

      elsif contents =~ /(黒|茶|赤|橙|黄|緑|青|紫|灰|白|金|銀)/ then
        return function.color_decode(contents)

      elsif contents =~ /(記録|きろく)/ then
        return function.record(username,str_time)

      else # どのキーワードにも当てはまらなかったら
        return function.conversation(contents,str_time)
      end
    end

    # OEbotを呼び出す
    def call(str_time)
      text = "はい\n#{str_time}"
      return text
    end

    # 現状を尋ねる
    def being(str_time)
      members = ""

      last_id = User.last.id
      last_id.times do |id|
        id = id + 1
        staytus = @data.staytus?(id)
        if staytus
          name = User.find(id).name
          members += name + ","
        end
      end

      if !(members.empty?) then
        text = "\n室内には\n#{members.chop} がいます。\n#{str_time}"
        return text
      else
        text = "\n室内には誰もいません。\n#{str_time}"
        return text
      end

    rescue => em
      print "being error "
      p em
    end

    # ping
    def ping(str_time)
      text = "pong\n#{str_time}"
      return text
    end

    # esysPinger (esysPinger.rb)
    def esys_pinger(str_time)
      room = PCroom.new(2..91,timeout:5)
      text = "\n機室では#{room.count(:on)}台が稼働中です。\n#{str_time}"
      return text
    end

    # L棟パンガチャ (gacha.rb)
    def ltou_gacha(str_time)
      gacha = Gacha.new()
      bun = gacha.buns_gacha()
      text = "本日のL棟パンは#{bun}です。\n#{str_time}"
      return text
    end

    # 抵抗値 -> カラーコード (color_code.rb)
    def color_encode(contents)
      contents = contents.gsub(/@open_esys\s/,"")
      contents = contents.gsub(/(Ω|オーム|\s|　)/,"")
      text = c_encode(contents)
      return text
    end

    # カラーコード -> 抵抗値 (color_code.rb)
    def color_decode(contents)
      contents = contents.gsub(/@open_esys\s/,"")
      contents = contents.gsub(/(\s|　|,|、)/,"")
      text = c_decode(contents)
      return text
    end

    # 訪問回数と合計滞在時間を返す
    def record(username,str_time)
      user = User.find_by_twitter_id(username)

      if user
        id = user.id
        # twitter_idがあれば（userがnilでない）idもあるが、訪問回数などは無い可能性がある。
        Condition.where(:user_id => id).first_or_create do |c|
          c.access_times = 0
          c.staying_time = 0
          c.save
        end
        condition = Condition.find_by_user_id(id)
        access_times = condition.access_times
        staying_time = time_to_str(condition.staying_time)
        text = "\nこれまでの訪問回数は#{access_times}回、\n合計滞在時間は#{staying_time}です。\n#{str_time}"
      else
        text = "3L502で登録してください。\n#{str_time}"
      end

      return text
    end

    # どのキーワードにも当てはまらなかったら (talk.rb)
    def conversation(contents,str_time)
      text = talk(contents)
      return "#{text}\n#{str_time}"
    end

    # 入室
    def in(id,str_time)
      command = "paplay ./voice/#{$okaeri.sample}"
      system(command)
      name = User.find(id).name
      text = "#{name}が入室しました。\n#{str_time}"
      return text
    end

    # 退室
    def out(id,str_time,staying_time)
      command = "paplay ./voice/nyanpass.wav"
      system(command)
      name = User.find(id).name
      text = "#{name}が退室しました。\n滞在時間は#{staying_time}です。\n#{str_time}"
      return text
    end

  end
end
