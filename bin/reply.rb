#!/usr/bin/env ruby
# coding:utf-8
require '../lib/bot.rb'

oebot = Bot.new(true)
mode = ARGV[0]
debug = false
if mode == "debug"
  debug = true
  puts "debugモードです"
end

begin
  oebot.timeline.userstream do |status|

    username = status.user.screen_name
    name = status.user.name
    contents = status.text
    id = status.id

    # リツイート以外を取得
    if !contents.index("RT") then

      # OEbotを呼び出す(他人へのリプを無視)
      if !(/^@\w*/.match(contents))
        if contents =~ /(おーいー|oe|OE|openesys|OpenEsys|open_esys|Open_Esys)(_||\s)(BOT|Bot|bot|ボット|ﾎﾞｯﾄ|ぼっと)/
          time = Time.now.strftime("[%Y-%m-%d %H:%M]")
          text = oebot.function.call(time)
          oebot.post(text,username,id,debug)
          oebot.fav(id)
        end
      end

      # 自分へのリプであれば
      if contents =~ /^@open_esys\s*/ then
        text = Bot::Function.generate_reply(contents)
        oebot.post(text,username,id,debug)
      end

    end

  sleep 2
  end
rescue => em
  puts Time.now
  p em
  sleep 1800
  retry
rescue Interrupt # ctrl + C
  exit 1
end
