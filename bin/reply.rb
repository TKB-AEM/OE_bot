#!/usr/bin/env ruby
# coding:utf-8

require '../lib/function/function.rb'

debug = false
OptionParser.new do |opt|
  opt.on('-d', '--debug','Switch to debug mode'){|v| debug = v}
  opt.parse!(ARGV)
end

oebot = Bot.new(debug:debug,mention:true)

system("clear")
puts "debug mode" if debug
puts "ready!"

begin
  oebot.timeline.userstream do |status|

    twitter_id = status.user.screen_name
    contents = status.text
    status_id = status.id

    not_RT = status.retweeted_status.nil?
    isMention = status.user_mentions.any? { |user| user.screen_name == oebot.name }
    isReply = contents.match(/^@\w*/)

    # リツイート以外を取得
    if not_RT

      # OEbotを呼び出す(他人へのリプを無視)
      if !isReply
        if contents.match(oebot.rep_table['self'][0])
          rep_text = Function.call(contents,table:oebot.rep_table)
          oebot.post(rep_text,twitter_id:twitter_id,status_id:status_id) if rep_text
          oebot.fav(status_id:status_id)
        end
      end

      # 自分へのリプであれば
      if isMention
        rep_text = Function.generate_reply(contents,oebot,twitter_id:twitter_id)
        oebot.post(rep_text,twitter_id:twitter_id,status_id:status_id) if rep_text
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
