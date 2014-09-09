#!/usr/bin/env ruby
# coding:utf-8

require "../lib/database/botuser.rb"

filename = "../list/backup.txt"
File.open(filename) do |io|
  io.each do |line|
    tmp = line.split(",")
    User.entry(tmp[1],tmp[2],tmp[3])
    Condition.where(:user_id => tmp[0]).first_or_create do |c|
      c.staytus = false
      c.access_times = tmp[4]
      c.staying_time = tmp[5]
    end
  end
end
puts "#{filename}からOE_bot.dbへのロードが完了しました。"
