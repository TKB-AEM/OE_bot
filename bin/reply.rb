#!/usr/bin/env ruby
# coding:utf-8

require '../lib/function/function.rb'

oebot = Bot.new(reply:true)
function = Function.new

mode = ARGV[0]
debug = false
if mode == "debug"
  debug = true
  puts "debugモードです"
end
puts "ready!"

begin
  oebot.timeline.userstream do |status|

    twitter_id = status.user.screen_name
    # name = status.user.name
    contents = status.text
    status_id = status.id

    # リツイート以外を取得
    if !contents.index("RT") then

      # OEbotを呼び出す(他人へのリプを無視)
      if !(/^@\w*/.match(contents))
        if contents =~ /(おーいー|oe|OE)(_||\s)(BOT|Bot|bot|ボット|ﾎﾞｯﾄ|ぼっと)/
          rep_text = function.call(contents)
          oebot.post(rep_text,twitter_id:twitter_id,status_id:status_id,debug:debug) if rep_text
          oebot.fav(status_id:status_id)
        end
      end

      # 自分へのリプであれば
      if contents =~ /^@open_esys\s*/ then
        rep_text = Function.generate_reply(contents,twitter_id:twitter_id,debug:debug)
        oebot.post(rep_text,twitter_id:twitter_id,status_id:status_id,debug:debug) if rep_text
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
