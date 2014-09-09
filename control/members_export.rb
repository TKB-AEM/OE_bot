#!/usr/bin/env ruby
# coding:utf-8

require "../lib/database/botuser.rb"

members_list = ""
last_id = User.last.id
last_id.times do |id|
  id = id + 1
  user = User.find(id:id)
  Condition.where(:user_id => id).first_or_create do |c|
    c.access_times = 0
    c.staying_time = 0
  end

  if !(user.condition.access_times)
    user.condition.access_times = 0
    user.condition.save
  end
  if !(user.condition.staying_time)
    user.condition.staying_time = 0
    user.condition.save
  end

  members_list += "#{user.id},#{user.name},#{user.twitter_id},#{user.card_id},"
  members_list += "#{user.condition.access_times},#{user.condition.staying_time}\n"
end

filename = "../list/backup.txt"
File.write(filename,members_list)
puts "#{filename}へのバックアップが完了しました。"
