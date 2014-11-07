# coding: utf-8

module OEbot
  class Condition < ActiveRecord::Base

    belongs_to :user

    # 状態の削除（id指定無しで全員）
    def Condition::clear(id:nil)
      if id
        condition = self.find_by_user_id(id)
        condition.delete
        condition.save
      else
        self.delete_all
      end
    rescue
      error_logs("clear", $!, $@)
    end

    # userの状態一覧を表示（id指定無しで全員表示）
    def Condition::show_contents(id:nil)
      if id
        condition = self.find_by_user_id(id)
        user = User.find(condition.user_id)
        puts "user_id       #{condition.user_id}"
        puts "name          #{user.name}"
        puts "entrance_time #{condition.entrance_time}"
        puts "exit_time     #{condition.exit_time}"
        puts "staytus       #{condition.staytus}"
        puts "access_times  #{condition.access_times}"
        puts "staying_time  #{condition.staying_time}"
        puts ""
      else
        self.all.each do |c|
          user = User.find(c.user_id)
          puts "user_id       #{c.user_id}"
          puts "name          #{user.name}"
          puts "entrance_time #{c.entrance_time}"
          puts "exit_time     #{c.exit_time}"
          puts "staytus       #{c.staytus}"
          puts "access_times  #{c.access_times}"
          puts "staying_time  #{c.staying_time}"
          puts ""
        end
      end
    rescue
      error_logs("show_contents", $!, $@)
    end

  end
end