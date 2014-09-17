#coding:utf-8

require 'open3'
require_relative "./esysPinger.rb"
require_relative "./gacha.rb"
require_relative "./color_code.rb"
require_relative "./talk.rb"

require_relative "../database/botuser.rb"
require_relative "../bot.rb"

$okaeri = ["okaeri1.wav","okaeri2.wav","okaeri3.wav","okaeri4.wav"]
PostError = Class.new(StandardError)

class Function

  def Function::generate_reply(contents = "",twitter_id:nil,debug:nil)
    function = new
    rep_text = ""

    if contents =~ /(おーいー|oe|OE|openesys|OpenEsys|open_esys|Open_Esys)(_||\s)(BOT|Bot|bot|ボット|ﾎﾞｯﾄ|ぼっと)/
      rep_text = function.call()

    elsif contents =~ /(誰か|だれか|誰が|だれが|おるか)/
      rep_text = function.being()

    elsif contents =~ /(記録|きろく)/
      rep_text = function.record(twitter_id:twitter_id)

    elsif contents =~ /(退室|たいしつ|退出|たいしゅつ)/
      rep_text = function.rep_exit(twitter_id:twitter_id,debug:debug)

    elsif contents =~ /(ping|Ping|PING)/
      rep_text = function.ping()

    elsif contents =~ /(計算機室|機室|きしつ)/
      rep_text = function.esys_pinger()

    elsif contents =~ /L棟(パン|ぱん)(ガチャ|がちゃ)/
      rep_text = function.ltou_gacha()

    elsif contents =~ /(say|Say|って言って|っていって)/
      rep_text = function.say(contents)

    elsif contents =~ /(Ω|オーム)/
      rep_text = function.color_encode(contents)

    elsif contents =~ /(黒|茶|赤|橙|黄|緑|青|紫|灰|白|金|銀)/
      rep_text = function.color_decode(contents)

    else # どのキーワードにも当てはまらなかったら
      rep_text = function.conversation(contents)
    end

    raise PostError.new('cannot reply, no text') if rep_text.nil? || rep_text.empty?
    return rep_text if rep_text

  rescue => em
    puts Time.now
    p em
  end

  # OEbotを呼び出す
  def call()
    text = "はい。"
    return text
  end

  # ダレカオルカ
  def being()
    members = ""

    last_id = User.last.id
    last_id.times do |id|
      id = id + 1
      user = BotUser.new(id:id)
      if user.staytus?
        name = user.name
        members += name + ","
      end
    end

    if !(members.empty?) then
      text = "\n室内には\n#{members.chop} がいます。"
      return text
    else
      text = "\n室内には誰もいません。"
      return text
    end

  rescue => em
    print "being error "
    p em
  end

  # 訪問回数と合計滞在時間を返す
  def record(twitter_id:"")
    user = User.find_by_twitter_id(twitter_id)

    if user
      condition = Condition.find_by_user_id(user.id)
      access_times = condition.access_times
      staying_time = time_to_str(condition.staying_time)
      text = "\nこれまでの訪問回数は#{access_times}回、\n合計滞在時間は#{staying_time}です。"
    else
      text = "3L502で登録してください。"
    end

    return text
  end

  # リプで退室する
  def rep_exit(twitter_id:"",debug:false)
    user = BotUser.new(twitter_id:twitter_id)
    if !(user.staytus?)
      text = "あなたは部屋にいません。"
      return text
    else
      time = Time.now + 60*60*9
      user.exit(time)
      staying_time = time_to_str(Condition.sum_time(id:user.id))
      text = self.out(id:user.id,staying_time:staying_time)
      Bot.new.post(text,debug:debug) if text
      text = "退室処理が完了しました。"
      return text
     end
  end

  # ping
  def ping()
    command = "ping -c 1 www.google.com -q; sort >&2"
    out ,error = Open3.capture3(command, :stdin_data=>"")

    if !error.empty?
      text = error
    else
      out = out.split("\n\n")
      text = out[0]
    end
    return text
  end

  # esysPinger (esysPinger.rb)
  def esys_pinger()
    room = PCroom.new(2..91,timeout:5)
    text = "\n機室では#{room.count(:on)}台が稼働中です。"
    return text
  end

  # L棟パンガチャ (gacha.rb)
  def ltou_gacha()
    gacha = Gacha.new()
    bun = gacha.buns_gacha()
    text = "本日のL棟パンは#{bun}です。"
    return text
  end

  # OpenJTalkでしゃべらせる
  def say(contents)
    contents = contents.gsub(/@\w*/,"")
    contents = contents.gsub(/(say|Say|って言って|っていって)/,"")
    contents = contents.gsub(/(\s|　|&|;)/,"")
    if !contents.empty? && !contents.nil?
      text = "「#{contents}」って言いました。"
      command = "sh ../lib/function/mei/say.sh #{contents}"
      system(command)
    else
      text = "セリフを指定してください。"
    end
    return text
  end

  # 抵抗値 -> カラーコード (color_code.rb)
  def color_encode(contents)
    contents = contents.gsub(/@\w*/,"")
    contents = contents.gsub(/(Ω|オーム|\s|　)/,"")
    text = c_encode(contents)
    return text
  end

  # カラーコード -> 抵抗値 (color_code.rb)
  def color_decode(contents)
    contents = contents.gsub(/@\w*/,"")
    contents = contents.gsub(/(\s|　|,|、)/,"")
    text = c_decode(contents)
    return text
  end

  # どのキーワードにも当てはまらなかったら (talk.rb)
  def conversation(contents)
    text = talk(contents)
    return text
  end

  #
  # 以下access.rb用（rep_exit()でも使用）
  #

  # 入室
  def in(id:nil)
    command = "paplay ./voice/#{$okaeri.sample}"
    system(command)
    name = User.find(id).name
    text = "#{name}が入室しました。"
    return text
  end

  # 退室
  def out(id:nil,staying_time:"0分")
    command = "paplay ./voice/nyanpass.wav"
    system(command)
    name = User.find(id).name
    text = "#{name}が退室しました。\n滞在時間は#{staying_time}です。"
    return text
  end

end

