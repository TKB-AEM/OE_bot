# coding: utf-8

module OEbot
  class DataBase

    attr_accessor :id, :name, :twitter_id, :card_id, :condition

    def self.last_id
      return User.last.id
    end

    def self.exist?(id:nil, twitter_id:nil)
      if id
        User.find(id)
        return true
      elsif twitter_id
        return User.find_by_twitter_id(twitter_id) ? true : false
      end
    rescue ActiveRecord::RecordNotFound
      return false
    end

    def initialize(id:nil, twitter_id:nil)
      if id
        @user = User.find(id)
        @id = id
        @twitter_id = @user.twitter_id
      elsif twitter_id
        @user = User.find_by_twitter_id(twitter_id)
        @id = @user.id
        @twitter_id = twitter_id
      end

      @name = @user.name
      @card_id = @user.card_id

      @condition = Condition.find_by_user_id(@id)

    rescue
      error_logs("database initialize", $!, $@)
      return nil
    end

    def staytus?
      Condition.where(:user_id => @id).first_or_create do |c|
        c.staytus = false
        c.save
      end
      return @user.condition.staytus
    rescue
      error_logs("staytus?", $!, $@)
      return false
    end

    # userを在室状態にする
    def entrance(time = nil)
      @user.condition.staytus = true
      @user.condition.entrance_time = time
      @user.condition.save
    rescue
      error_logs("entrance", $!, $@)
    end

    # userを不在状態にし、訪問回数を加算する
    def exit(time = nil)
      @user.condition.staytus = false
      @user.condition.exit_time = time
      @user.condition.access_times += 1
      @user.condition.save
    rescue
      error_logs("exit", $!, $@)
    end

    def rank
      members_num = User.last.id
      my_rank = members_num
      User.all.each do |u|
        next if @id == u.id
        my_rank -= 1 if u.condition.staying_time <= @user.condition.staying_time
      end
      return my_rank
    end

    # staying_time、合計滞在時間を計算する 必ずexit()の後に
    # またその都度の滞在時間を返す
    def cal_stayingtime
      # 何故かインスタンス変数からだとうまくいかない
      botuser = User.find(@id)
      entrance = botuser.condition.entrance_time
      exit = botuser.condition.exit_time

      entrance_m = entrance.min
      entrance_h = entrance.hour
      exit_m = exit.min
      exit_h = exit.hour

      min = exit_m - entrance_m
      if min < 0
        min += 60
        entrance_h += 1
        entrance_h = 0 if entrance_h == 24
      end
      hour = exit_h - entrance_h
      hour += 24 if hour < 0

      @user.condition.staying_time += hour*60 + min
      @user.condition.save

      return hour*60 + min
    rescue
      error_logs("sum_time", $!, $@)
    end

  end
end