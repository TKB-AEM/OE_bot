#coding:utf-8

require 'active_record'

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => "../lib/database/OE_bot.db"
)

class User < ActiveRecord::Base
  validates :name, :presence => true
  I18n.enforce_available_locales = false
  has_one :condition ,:dependent => :destroy
end

class Condition < ActiveRecord::Base
  belongs_to :user
end

class Database

  def initialize
  end

  # 新規登録
  def entry(name,twitter_id,card_id)
    user = User.new do |u|
      u.name = name
      u.twitter_id = twitter_id
      u.card_id = card_id
    end
    user.save

    if !user.save # validates
      puts "entry error #{user.errors.messages}\n\n"
    end
  end

  # 既に登録してあるひとの上書き
  def update(id,name,twitter_id,card_id)
    user = User.find(id) do |u|
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
  def user_clear(id = nil)
    if id
      user = User.find(id)
      user.destroy
      user.save
    else
      User.destroy_all
    end

  rescue => em
    print "user_clear error "
    p em
  end

  # 状態の削除（id指定無しで全員）
  def condition_clear(id = nil)
    if id
      condition = Condition.find(id)
      condition.delete
      condition.save
    else
      Condition.delete_all
    end

  rescue => em
    print "condition_clear error "
    p em
  end

  # userの情報を表示（id指定無しで全員表示）
  def show_user_contents(id = nil)

    if id
      user = User.find(id)
      puts "id         #{user.id}"
      puts "name       #{user.name}"
      puts "twitter_id #{user.twitter_id}"
      puts "card_id    #{user.card_id}"
      puts ""

    else
      User.all.each do |u|
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

  # userの状態一覧を表示（id指定無しで全員表示）
  def show_condition_contents(id = nil)

    if id
      condition = Condition.find(id)
      puts "user_id       #{condition.user_id}"
      puts "entrance_time #{condition.entrance_time}"
      puts "exit_time     #{condition.exit_time}"
      puts "staytus       #{condition.staytus}"
      puts "access_times  #{condition.access_times}"
      puts "staying_time  #{condition.staying_time}"
      puts ""

    else
      Condition.all.each do |c|
        puts "user_id       #{c.user_id}"
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

  # userのidによって、在室か否かを返す
  def staytus?(id = nil)
    Condition.where(:user_id => id).first_or_create do |c|
      c.staytus = false
      c.save
    end

    user = User.find(id)
    return user.condition.staytus

  rescue => em
    print "staytus? error "
    p em
  end

  # 渡されたidの人を在室状態にする
  def entrance(id = nil,time = nil)
    user = User.find(id)
    user.condition.staytus = true
    user.condition.entrance_time = time
    user.condition.save

  rescue => em
    print "entrance error "
    p em
  end

  # 渡されたidの人を不在状態にし、訪問回数を加算する
  def exit(id = nil,time = nil)
    user = User.find(id)
    user.condition.staytus = false
    user.condition.exit_time = time

    if !(user.condition.access_times)
      user.condition.access_times = 0
    end
    user.condition.access_times += 1
    user.condition.save

  rescue => em
    print "exit error "
    p em
  end

  # 渡されたidの人の在室状態を変更する
  def access(id = nil,time = nil,staytus = false)
    Condition.where(:user_id => id).first_or_create do |c|
      c.staytus = staytus
      c.save
    end

    user = User.find(id)
    user.condition.staytus = staytus
    user.condition.entrance_time = time
    user.condition.save

  rescue => em
    print "access error "
    p em
  end

  # staying_time、合計滞在時間を計算する 必ずexit()の後に
  # またその都度の滞在時間を返す
  def sum_time(id = nil)
    user = User.find(id)
    entrance = user.condition.entrance_time
    exit = user.condition.exit_time

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

    if !(user.condition.staying_time)
      user.condition.staying_time = 0
    end
    user.condition.staying_time += hour*60 + min
    user.condition.save

    return hour*60 + min

  rescue => em
    print "sum_time error "
    p em
  end

end
