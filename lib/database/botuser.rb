#coding:utf-8

require_relative "./database.rb"
require_relative "../database/helper.rb"

class BotUser

  attr_accessor :id,:name,:twitter_id,:card_id

  def initialize(id:nil,twitter_id:nil)
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

  rescue => em
    print "initialize error "
    p em
  end

  # userが在室であるか否かを返す
  def staytus?
    Condition.where(:user_id => @id).first_or_create do |c|
      c.staytus = false
      c.save
    end

    return @user.condition.staytus

  rescue => em
    print "staytus? error "
    p em
  end

  # userを在室状態にする
  def entrance(time = nil)
    @user.condition.staytus = true
    @user.condition.entrance_time = time
    @user.condition.save

  rescue => em
    print "entrance error "
    p em
  end

  # userを不在状態にし、訪問回数を加算する
  def exit(time = nil)
    @user.condition.staytus = false
    @user.condition.exit_time = time
    @user.condition.access_times += 1
    @user.condition.save

  rescue => em
    print "exit error "
    p em
  end

  def rank
    members_num = User.last.id
    my_rank = members_num
    User.all.each do |u|
      next if @user.id == u.id
      my_rank -= 1 if u.condition.staying_time <= @user.condition.staying_time
    end
    return my_rank
  end

end
