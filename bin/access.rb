#!/usr/bin/env ruby
# coding:utf-8

require "../lib/bot.rb"

oebot = Bot.new()
card = Card.new()
data = Database.new()
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
  data = Database.new()
  print "ฅ(๑'Δ'๑) 名前を入力してください："
  name = STDIN.gets.chomp.to_s
  print "ฅ(๑'Δ'๑) twitter idを入力してください："
  twitter_id = STDIN.gets.chomp.to_s
  data.entry(name,twitter_id,card_id)
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
    id = card.check(card_id)

    time = Time.now + 60*60*9

    # idが既にある場合（登録済み）
    if id
      staytus = data.staytus?(id)
      str_time = Time.now.strftime("[%Y-%m-%d %H:%M]")

      if !staytus
        data.entrance(id,time)
        text = oebot.function.in(id,str_time)
        oebot.post(text,nil,nil,debug)
      else
        data.exit(id,time)
        staying_time = time_to_str(data.sum_time(id))
        text = oebot.function.out(id,str_time,staying_time)
        oebot.post(text,nil,nil,debug)
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
