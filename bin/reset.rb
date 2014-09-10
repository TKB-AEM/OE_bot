# coding:utf-8

require '../lib/bot.rb'
require '../lib/database/botuser.rb'
require 'clockwork'

module Clockwork

  handler do |job|

    case job

    when 'reset.job'
      oebot = Bot.new
      debug = false

      last_id = User.last.id
      last_id.times do |id|
        id = id + 1
        user = User.find(id)
        user.condition.staytus = false
        user.condition.save
      end

      str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")
      text = "在室情報をリセットしました。"
      text += "\n#{str_time}"
      oebot.post(text,debug:debug)

    when 'backup.job'
      system("ruby ../control/members_export.rb")
    end

  end

  # 朝６時になったら部屋にいる人をクリアする
  every(1.day, 'reset.job', :at => '06:00')
  # データベースのバックアップをとる
  every(1.day, 'backup.job', :at => '06:30')
end
