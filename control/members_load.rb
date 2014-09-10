#!/usr/bin/env ruby
# coding:utf-8

require "../lib/database/botuser.rb"

filename = "../list/backup.txt"
File.open(filename) do |io|
  io.each do |line|
    tmp = line.split(",")
    User.entry(name:tmp[1],twitter_id:tmp[2],card_id:tmp[3])
    user = User.find(tmp[0].to_i)
    user.condition.access_times = tmp[4]
    user.condition.staying_time = tmp[5]
    user.condition.save
  end
end

puts "#{filename}からOE_bot.dbへのロードが完了しました。"
