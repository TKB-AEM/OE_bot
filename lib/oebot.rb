# coding: utf-8
$:.unshift File.dirname(__FILE__)

require 'twitter'
require 'tweetstream'
require 'yaml'
require 'pp'
require 'active_record'
require 'pasori'
require 'open3'
require 'net/ping'
require 'net/ssh'
require 'nkf'
require 'clockwork'
require 'parallel'

require_relative "oebot/function/helper"
require_relative "oebot/database/helper"

def error_logs(text, message, point)
  puts Time.now
  puts "#{text} error! #{message.class}: #{message}\n#{point[0]}"
  puts ""
end

module OEbot
  require_relative "oebot/database/user"
  require_relative "oebot/database/condition"
  require_relative "oebot/database"

  require_relative "oebot/function/oruka"
  require_relative "oebot/function/colorcode"
  require_relative "oebot/function/pcnode"
  require_relative "oebot/function/pcroom"
  require_relative "oebot/function/etcetera"
  require_relative "oebot/function"

  require_relative "oebot/bot"
  require_relative "oebot/card"

  module_function

  # 登録用
  def sign_up(oebot,card_id:nil)
    twitter_error_message = "※半角英数字およびアンダーバーのみでお願いします(@は不要です)"
    system("clear")
    name = ""
    twitter_id = ""

    # 名前を入力
    loop do
      print "ฅ(๑'Δ'๑) 名前を入力してください："
      name = STDIN.gets.chomp.to_s
      system("clear")
      break unless name.empty?
      puts "※何か入力してください"
    end

    # ツイッターIDを入力
    loop do
      puts "※Twitterと連携しない場合は何も入力せずにEnterを押してください"
      print "ฅ(๑'Δ'๑) twitter idを入力してください："
      twitter_id = STDIN.gets.chomp.to_s

      # 半角英数字およびアンダーバー以外を除外
      if twitter_id.split("").any? {|v| v.match(/[^ -~]/)}
        system("clear")
        puts twitter_error_message
        redo
      elsif twitter_id.split("").any? {|v| v.match(/[^\w]/)}
        system("clear")
        puts twitter_error_message
        redo
      end
      break
    end

    error_messages = OEbot::User.entry(name, twitter_id, card_id)
    # なんちゃって一意性
    if error_messages
      error_messages.each_key do |key|
        column = case key
        when :name       then "名前"
        when :twitter_id then "ツイッターアカウント"
        when :card_id    then "FeliCa"
        end
        puts "\n（☝◞‸◟）☝ その#{column}は既に登録されています！"
      end
    else
      puts "(๑¯Δ¯๑)/ 登録が完了しました!"
      command = "paplay ./voice/entry.wav"
      system(command)
      unless twitter_id.empty?
        rep_text = "ようこそ、#{name}さん!フォローにはしばらく時間がかかることがあるかもです。"
        oebot.post(rep_text,twitter_id:twitter_id)
      end
    end
  rescue Interrupt
    return nil
  end
end