#coding:utf-8

require 'active_record'

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => "../lib/database/OE_bot.db"
)

class User < ActiveRecord::Base

  validates :name,       :presence => true, :uniqueness => true
  validates :twitter_id, :presence => true, :uniqueness => true
  validates :card_id,    :presence => true, :uniqueness => true
  I18n.enforce_available_locales = false
  has_one :condition ,:dependent => :destroy

  # 新規登録
  def User::entry(name:"",twitter_id:"",card_id:"")
    user = self.new do |u|
      u.name = name
      u.twitter_id = twitter_id unless twitter_id.empty?
      u.twitter_id ||= card_id
      u.card_id = card_id
    end
    user.save

    return user.errors.messages if !user.save

    # first_or_createをしなくてよくなる
    condition = Condition.new do |c|
      c.user_id = user.id
      c.staytus = false
      c.access_times = 0
      c.staying_time = 0
    end
    condition.save
    return nil

  end

  # 既に登録してあるuserの上書き
  def User::update(id:nil,name:"",twitter_id:"",card_id:"")
    user = self.find(id) do |u|
      u.name = name
      u.twitter_id = twitter_id
      u.card_id = card_id
    end
    user.save

    if !user.save # validates
      puts "update error #{user.errors.messages}\n\n"
    end

  rescue => em
    print "update error "
    p em
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

  rescue => em
    print "user_clear error "
    p em
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

  rescue => em
    puts "show_user_contents error "
    p em
  end

end



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

  rescue => em
    print "condition_clear error "
    p em
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

  rescue => em
    puts "show_condition_contents error "
    p em
  end

  # staying_time、合計滞在時間を計算する 必ずexit()の後に
  # またその都度の滞在時間を返す
  def Condition::sum_time(id:nil)
    condition = self.find_by_user_id(id)
    entrance = condition.entrance_time
    exit = condition.exit_time

    entrance_m = entrance.min
    entrance_h = entrance.hour
    exit_m = exit.min
    exit_h = exit.hour

    min = (exit_m - entrance_m)
    if min < 0
      min += 60
      entrance_h += 1
      if entrance_h == 24
        entrance_h = 0
      end
    end

    hour = (exit_h - entrance_h)
    if hour < 0
      hour += 24
    end

    if !(condition.staying_time)
      condition.staying_time = 0
    end
    condition.staying_time += hour*60 + min
    condition.save

    return hour*60 + min

  rescue => em
    print "sum_time error "
    p em
  end

end
