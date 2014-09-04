# coding:utf-8

require '../lib/bot.rb'
require 'clockwork'

module Clockwork

  handler do |job|

    case job

    when 'reset.job'
      data = Database.new()
      oebot = Bot.new()
      debug = false

      last_id = User.last.id

      last_id.times do |id|
        id = id + 1

        Condition.where(:user_id => id).first_or_create do |c|
          c.staytus = false
          c.save
        end

        staytus = data.staytus?(id)
        user = User.find(id)
        user.condition.staytus = false
        user.condition.save
      end

      str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")
      text = "在室情報をリセットしました。\n#{str_time}"
      oebot.post(text,nil,nil,debug)

    end
  end

  # 朝６時になったら部屋にいる人をクリアする
  every(1.day, 'reset.job', :at => '06:00')
end
