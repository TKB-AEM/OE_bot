#!/usr/bin/env ruby
# coding:utf-8

require "../lib/database/database.rb"

data = Database.new()

File.open("../list/backup.txt") do |io|
  io.each do |line|
    tmp = line.split(",")
    data.entry(tmp[1],tmp[2],tmp[3])
    Condition.where(:user_id => tmp[0]).first_or_create do |c|
      c.access_times = tmp[4]
      c.staying_time = tmp[5]
    end
  end
end

data.show_user_contents()
data.show_condition_contents()
