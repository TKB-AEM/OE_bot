#coding:utf-8
require_relative "./esysPinger.rb"
require_relative "./gacha.rb"
require_relative "./color_code.rb"
require_relative "./talk.rb"

$okaeri = ["okaeri1.wav","okaeri2.wav","okaeri3.wav","okaeri4.wav"]

class Bot
  class Function

    def Function::generate_reply(contents)
      function = new
      time = Time.now.strftime("[%Y-%m-%d %H:%M]")
      # time_s = Time.now.strftime("%H時%M分%S秒")
      if contents =~ /(おーいー|oe|OE|openesys|OpenEsys|open_esys|Open_Esys)(_||\s)(BOT|Bot|bot|ボット|ﾎﾞｯﾄ|ぼっと)/ then
        return function.call(time)
      elsif contents =~ /(誰か|だれか|誰が|だれが|おるか)/ then
        return function.being(time)
      elsif contents =~ /(ping|Ping|PING)/ then
        return function.ping(time)
      elsif contents =~ /(計算機室|機室|きしつ)/ then
        return function.esys_pinger(time)
      elsif contents =~ /L棟(パン|ぱん)(ガチャ|がちゃ)/ then
        return function.ltou_gacha(time)
      elsif contents =~ /(Ω|オーム)/ then
        return function.color_encode(contents)
      elsif contents =~ /(黒|茶|赤|橙|黄|緑|青|紫|灰|白|金|銀)/ then
        return function.color_decode(contents)
      else # どのキーワードにも当てはまらなかったら
        return function.conversation(contents,time)
      end
    end

    # OEbotを呼び出す
    def call(time)
      text = "はい\n#{time}"
      return text
    end

    # 現状を尋ねる
    def being(time)
      members = ""
      File.open("../list/be_in.txt") do |io|
        io.each do |line|
          members += line.to_s
        end
      end
      if !(members.empty?) then
        text = "\n室内には\n#{members} がいます。\n#{time}"
        return text
      else
        text = "\n室内には誰もいません。\n#{time}"
        return text
      end
    end

    # ping
    def ping(time)
      text = "pong\n#{time}"
      return text
    end

    # esysPinger (esysPinger.rb)
    def esys_pinger(time)
      room = PCroom.new(2..91,timeout:5)
      text = "\n機室では#{room.count(:on)}台が稼働中です。\n#{time}"
      return text
    end

    # L棟パンガチャ (gacha.rb)
    def ltou_gacha(time)
      gacha = Gacha.new()
      bun = gacha.buns_gacha()
      text = "本日のL棟パンは#{bun}です。\n#{time}"
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

    # どのキーワードにも当てはまらなかったら (talk.rb)
    def conversation(contents,time)
      text = talk(contents)
      return "#{text}\n#{time}"
    end

    # 退室
    def out(list,leaver,time)
      text = "#{leaver[0]}が退室しました。\n#{time}"
      command = "paplay ./voice/nyanpass.wav"
      system(command)
      members = ""
      list.each{ |member|
        members += (member) + ","
      }
      File.write("../list/be_in.txt",members.chop)
      return text
    end

    # 入室
    def in(list,newcomer,time)
      text = "#{newcomer}が入室しました。\n#{time}"
      command = "paplay ./voice/#{$okaeri.sample}"
      system(command)
      members = ""
      list.each{ |member|
        members += (member) + ","
      }
      File.write("../list/be_in.txt",members.chop)
      return text
    end

  end
end
