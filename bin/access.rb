#!/usr/bin/env ruby
# coding:utf-8

require "../lib/card.rb"

oebot = Bot.new()
function = Function.new()
card = Card.new()
list = Array.new()
i = 0
input = ""

mode = ARGV[0]
debug = false
if mode == "debug"
  debug = true
end

# 登録用
def to_entry(card_id)
  print "ฅ(๑'Δ'๑) 名前を入力してください："
  name = STDIN.gets.chomp.to_s
  print "ฅ(๑'Δ'๑) twitter idを入力してください："
  twitter_id = STDIN.gets.chomp.to_s
  User.entry(name:name,twitter_id:twitter_id,card_id:card_id)
  puts "(๑¯Δ¯๑)/ 登録が完了しました!"
end

begin
  loop do

    system("clear")
    if debug
      puts "debugモードです"
    end

    puts "ฅ(๑'Δ'๑) カードを置いてください。"
    card_id = Card.idnum()
    # card_id = STDIN.gets.to_s.chomp
    id = card.check(card_id)

    # idが既にある場合（登録済み）
    if id
      user = BotUser.new(id:id)
      staytus = user.staytus?
      time = Time.now + 60*60*9
      str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")

      if !staytus
        user.entrance(time)
        text = function.in(id:id)
        text += "\n#{str_time}"
        oebot.post(text,debug:debug)
      else
        user.exit(time)
        staying_time = time_to_str(Condition.sum_time(id:id))
        text = function.out(id:id,staying_time:staying_time)
        text += "\n#{str_time}"
        oebot.post(text,debug:debug)
      end

    # idが見つからない場合（未登録）
    else
      loop do
        puts "（☝◞‸◟）☝ あなたはまだ登録されていません"
        print "ฅ(๑'Δ'๑) 登録しますか(y/n)? :"
        input = STDIN.gets.to_s.chomp

        if input == "y" || input == "Y"
          to_entry(card_id)
          break
        elsif input == "n" || input == "N"
          break
        else
          system("clear")
          puts "(๑¯Δ¯๑)/ もういちど入力してください。\n\n"
          redo
        end

      end
    end

    sleep 5
  end

rescue Interrupt
  exit 1

rescue => em
  p em
  sleep 3
  retry
end
