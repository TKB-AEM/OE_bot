# coding:utf-8

require '../lib/bot.rb'
require '../lib/database/botuser.rb'
require 'clockwork'

module Clockwork

  handler do |job|

    case job

    when 'reset_job'
      debug = false
      oebot = Bot.new(debug:debug)

      last_id = User.last.id
      last_id.times do |id|
        id = id + 1
        user = User.find(id)
        user.condition.staytus = false
        user.condition.save
      end

      text = "在室情報をリセットしました。"
      oebot.post(text) if text

    when 'backup_job'
      system("ruby ../control/export.rb")
    end

  end

  # 朝６時になったら部屋にいる人をクリアする
  every(1.day, 'reset_job', :at => '06:00')
  # データベースのバックアップをとる
  every(1.day, 'backup_job', :at => '06:30')
end
