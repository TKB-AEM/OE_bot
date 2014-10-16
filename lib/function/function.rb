#coding:utf-8

require 'open3'
require_relative "./esysPinger.rb"
require_relative "./gacha.rb"
require_relative "./color_code.rb"

require_relative "../database/botuser.rb"
require_relative "../bot.rb"

PostError = Class.new(StandardError)

module Function

  def generate_reply(contents = "",oebot,twitter_id:nil)

    rep_text = case contents
      when /(誰か|だれか|誰が|だれが|おるか)/
        being()
      when /(記録|きろく)/
        record(twitter_id:twitter_id)
      when /(退室|たいしつ|退出|たいしゅつ)/
        rep_exit(oebot,twitter_id:twitter_id)
      when /ping/i
        ping()
      when /(計算機室|機室|きしつ)/
        esys_pinger()
      when /L棟(パン|ぱん)(ガチャ|がちゃ)/
        ltou_gacha(oebot.config['buns_list'])
      when /(say|って言って|っていって)/i
        say(contents)
      when /(Ω|オーム)/
        cc_encode(contents)
      when /(黒|茶|赤|橙|黄|緑|青|紫|灰|白|金|銀)/
        cc_decode(contents)
      else # どのキーワードにも当てはまらなかったら
        conversation(contents,table:oebot.rep_table)
      end

    raise PostError.new('cannot reply, no text') if rep_text.nil? || rep_text.empty?
    return rep_text if rep_text

  rescue => em
    puts Time.now
    p em
  end

  #
  # いわゆる空中に反応する用
  #

  # OEbotを呼び出す
  def call(contents,table:nil)
    text = nil
    text = table['call'][1].sample if contents.match(table['call'][0])
    return text
  end

  #
  # リプライ用
  #

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
      staying_time = (condition.staying_time).minutes_to_s
      text = "\nこれまでの訪問回数は#{access_times}回、\n合計滞在時間は#{staying_time}です。"
    else
      text = "3L502で登録してください。"
    end

    return text
  end

  # リプで退室する
  def rep_exit(oebot,twitter_id:"")

    if User.find_by_twitter_id(twitter_id)
      user = BotUser.new(twitter_id:twitter_id)
      if user.staytus?
        time = Time.now + 60*60*9
        user.exit(time)
        staying_time = (Condition.sum_time(id:user.id)).minutes_to_s
        text = out(id:user.id,staying_time:staying_time)
        oebot.post(text) if text
        text = "退室処理が完了しました。"
      else
        text = "あなたは部屋にいません。"
      end
    else
      text = "3L502で登録してください。"
    end

    return text
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
  def ltou_gacha(buns_list)
    gacha = Gacha.new(buns_list)
    bun = gacha.buns_gacha()
    text = "本日のL棟パンは#{bun}です。"
    return text
  end

  # OpenJTalkでしゃべらせる
  def say(contents)
    contents = contents.gsub(/@\w*/,"")
    contents = contents.sub(/(say|って言って|っていって)/i,"")
    contents = contents.gsub(/(\s|　|\(|\)|\||{|}|&|;|`|\$|emacs|rm|SHELL|irb)/,"")
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
  def cc_encode(contents)
    contents = contents.gsub(/@\w*/,"")
    contents = contents.gsub(/(Ω|オーム|\s|　)/,"")
    text = ColorCode.encode(contents)
    return text
  end

  # カラーコード -> 抵抗値 (color_code.rb)
  def cc_decode(contents)
    contents = contents.gsub(/@\w*/,"")
    contents = contents.gsub(/(\s|　|,|、)/,"")
    text = nil
    catch(:error) do
      contents.split("").each do |color|
        throw :error unless color =~ /(黒|茶|赤|橙|黄|緑|青|紫|灰|白|金|銀)/
      end
      text = ColorCode.decode(contents)
    end
    text ||= self.conversation(contents)
    return text
  end

  # どのキーワードにも当てはまらなかったら
  def conversation(contents,table:nil)
    text = nil
    catch(:exit) do
      if contents.match(table['self'][0])
        text = table['self'][1].sample
        throw :exit
      end

      table['comprehensible'].each do |row|
        if row[0].any? {|keyword| contents.index(keyword) }
          text = row[1].sample
          throw :exit
        end
      end
    end

    text ||= table['incomprehensible'].sample
    return text
  end

  #
  # 以下access.rb用（rep_exit()でも使用）
  #

  # 入室
  def in(id:nil)
    okaeri = ["okaeri1.wav","okaeri2.wav","okaeri3.wav","okaeri4.wav"]
    command = "paplay ./voice/#{okaeri.sample}"
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

  module_function \
    :generate_reply,
    :call,
    :being,:record,:rep_exit,:ping,:esys_pinger,:ltou_gacha,:say,
    :cc_encode,:cc_decode,
    :conversation,
    :in, :out

end

