# coding: utf-8

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => "../lib/oebot/database/OE_bot.db"
)

module OEbot
  class User < ActiveRecord::Base

    validates :name,       :presence => true, :uniqueness => true
    validates :twitter_id, :presence => true, :uniqueness => true
    validates :card_id,    :presence => true, :uniqueness => true
    I18n.enforce_available_locales = false
    has_one :condition ,:dependent => :destroy

    # 新規登録
    def User::entry(name, twitter_id, card_id)
      user = self.new do |u|
        u.name = name
        u.twitter_id = twitter_id unless twitter_id.empty?
        u.twitter_id ||= card_id
        u.card_id = card_id
      end
      user.save
      raise StandardError.new("validates error") if !user.save

      # first_or_createをしなくてよくなる
      condition = Condition.new do |c|
        c.user_id = user.id
        c.staytus = false
        c.access_times = 0
        c.staying_time = 0
      end
      condition.save
      return
    rescue
      return user.errors.messages
    end

    # 情報の削除（id指定無しで全員）
    def User::clear(id:nil)
      if id
        user = self.find(id)
        user.destroy
        user.save
      else
        self.destroy_all
      end
    rescue
      error_logs("clear", $!, $@)
    end

    # userの情報を表示（id指定無しで全員表示）
    def User::show_contents(id:nil)
      if id
        user = self.find(id)
        puts "id         #{user.id}"
        puts "name       #{user.name}"
        puts "twitter_id #{user.twitter_id}"
        puts "card_id    #{user.card_id}"
        puts ""

      else
        self.all.each do |u|
          puts "id         #{u.id}"
          puts "name       #{u.name}"
          puts "twitter_id #{u.twitter_id}"
          puts "card_id    #{u.card_id}"
          puts ""
        end
      end

    rescue
      error_logs("show_contents", $!, $@)
    end
  end
end