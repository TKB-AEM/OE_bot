#!/usr/bin/env ruby
# coding:utf-8
require '../lib/bot.rb'
require '../lib/card.rb'

oebot = Bot.new()
card = Card.new()
list = Array.new()
i = 0
input = ""

mode = ARGV[0]
debug = false
if mode == "debug"
  debug = true
  puts "debugモードです"
end

# 朝６時になったら部屋にいる人をクリアする
clear = Thread.new() do
  loop do
    now = Time.now.strftime("%H")
    if now == "06"
      time = Time.now.strftime("[%Y-%m-%d %H:%M]")
      File.write("../list/be_in.txt",nil)
      list = []
      puts ""
      text = "在室情報をリセットしました。\n#{time}"
      oebot.post(text,nil,nil,debug)
      print "ฅ(๑'Δ'๑) あなたは既に登録されてますか(y/n)? :"
    end
    sleep 3600
  end
end

card.reload # members.csv から
begin
  loop do
    print "ฅ(๑'Δ'๑) あなたは既に登録されてますか(y/n)? :"
    input = STDIN.gets.to_s.chomp

    if input == "y" || input == "Y" then
      puts "ฅ(๑'Δ'๑) カードを置いてください。"
      # カードを読むまで諦めない
      num = Card.idnum()
      # members.csv にないIDが読み込まれた場合guest(数字)と表示される
      if card.hash(num).nil? then
        card.reload_guest(num,"guest(#{i})")
        i += 1
      end
      list << card.hash(num)
      # 重複した人物は退室
      leaver = list.uniq.select{|i| list.index(i) != list.rindex(i)}
      time = Time.now.strftime("[%Y-%m-%d %H:%M]")
      if !(leaver.empty?) then
        list = list - leaver
        text = oebot.function.out(list,leaver,time)
        oebot.post(text,nil,nil,debug)
      else
        text = oebot.function.in(list,card.hash(num),time)
        oebot.post(text,nil,nil,debug)
      end
      sleep 3

    elsif input == "n" || input == "N" then
      print "ฅ(๑'Δ'๑) 名前を入力してください："
      name = STDIN.gets.chomp!.to_s
      puts "ฅ(๑'Δ'๑) カードを置いてください"
      id_num = Card.idnum()
      file_name = "../list/members.csv"
      new_member = "#{id_num},#{name}\n"
      entry = File.open(file_name,"a")
      entry.write(new_member)
      entry.close
      puts "(๑¯Δ¯๑)/ 登録が完了しました!\n\n"
      card.reload # members.csv から
      sleep 3

    else
      puts "(๑¯Δ¯๑)/ もういちど入力してください。\n\n"
      redo
    end

    input = ""
  end

rescue Interrupt # ctrl + C
  exit 1
rescue => em
  p em
  sleep 3
  retry
end

clear.join
