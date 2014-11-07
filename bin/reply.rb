#!/usr/bin/env ruby
# coding: utf-8

require "../lib/oebot"

debug = false
OptionParser.new do |opt|
  opt.on('-d', '--debug','Switch to debug mode'){|v| debug = v}
  opt.parse!(ARGV)
end

oebot = OEbot::Bot.new(debug:debug, mention:true)

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

    # puts "twitter_id #{twitter_id}"
    # puts "contents   #{contents}"
    # puts "status_id  #{status_id}"
    # puts ""

    # リツイート以外を取得
    if not_RT
      # リプライでない通常の投稿であれば
      if !isReply
        res_text = oebot.generate_response(contents, status_id, oebot)
        oebot.post(res_text, twitter_id:twitter_id, status_id:status_id) if res_text
      end

      # 自分へのリプであれば
      if isMention
        rep_text = oebot.generate_reply(contents, twitter_id, oebot)
        oebot.post(rep_text, twitter_id:twitter_id, status_id:status_id) if rep_text
      end
    end

    sleep 2
  end

rescue Interrupt
  exit 1
rescue
  error_logs("reply", $!, $@)
  sleep 300
  retry
end
