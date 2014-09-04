#!/usr/bin/env ruby
# coding:utf-8

require '../lib/bot.rb'

$oebot = Bot.new(true)
$data = Database.new()
mode = ARGV[0]
debug = false

if mode == "debug"
  debug = true
  puts "debugモードです"
end

# リプで退室する
def rep_exit(str_time,username,debug)
  id = User.find_by_twitter_id(username).id
  if !($data.staytus?(id))
    text = "あなたは部屋にいません。\n#{str_time}"
    return text
  else
    time = Time.now + 60*60*9
    $data.exit(id,time)
    staying_time = time_to_str($data.sum_time(id))
    text = $oebot.function.out(id,str_time,staying_time)
    $oebot.post(text,nil,nil,debug)
    text = "退室処理が完了しました。\n#{str_time}"
    return text
  end
end

begin
  $oebot.timeline.userstream do |status|

    username = status.user.screen_name
    name = status.user.name
    contents = status.text
    id = status.id

    # リツイート以外を取得
    if !contents.index("RT") then

      # OEbotを呼び出す(他人へのリプを無視)
      if !(/^@\w*/.match(contents))
        if contents =~ /(おーいー|oe|OE|openesys|OpenEsys|open_esys|Open_Esys)(_||\s)(BOT|Bot|bot|ボット|ﾎﾞｯﾄ|ぼっと)/
          str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")
          text = $oebot.function.call(str_time)
          $oebot.post(text,username,id,debug)
          $oebot.fav(id)
        end
      end

      # 自分へのリプであれば
      if contents =~ /^@open_esys\s*/ then
        if contents =~ /退室/
          str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")
          text = rep_exit(str_time,username,debug)
        else
          text = Bot::Function.generate_reply(contents,username,debug)
        end

        $oebot.post(text,username,id,debug)
      end

    end

  sleep 2
  end

rescue => em
  puts Time.now
  p em
  sleep 1800
  retry

rescue Interrupt
  exit 1
end
