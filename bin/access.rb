#!/usr/bin/env ruby
# coding:utf-8

require "../lib/card.rb"

debug = false
pasori = true
OptionParser.new do |opt|
  opt.on('-d', '--debug','Switch to debug mode'){|v| debug = v}
  opt.on('--[no-]pasori','Select whether to use PaSoRi or not'){|v| pasori = v}
  opt.parse!(ARGV)
end

oebot = Bot.new(debug:debug)

# 登録用
def to_entry(oebot,card_id,debug)
  print "ฅ(๑'Δ'๑) 名前を入力してください："
  name = STDIN.gets.chomp.to_s
  print "ฅ(๑'Δ'๑) twitter idを入力してください："
  twitter_id = STDIN.gets.chomp.to_s
  twitter_id = twitter_id.gsub(/@/,"")
  User.entry(name:name,twitter_id:twitter_id,card_id:card_id)
  puts "(๑¯Δ¯๑)/ 登録が完了しました!"
  command = "paplay ./voice/entry.wav"
  system(command)
  rep_text = "ようこそ、#{name}さん!フォローにはしばらく時間がかかることがあるかもです。"
  oebot.post(rep_text,twitter_id:twitter_id)
end

begin
  loop do

    system("clear")
    puts "debug mode" if debug

    puts "ฅ(๑'Δ'๑) カードを置いてください。"

    # PaSoRiがない場合番号を手動入力する
    if pasori
      card = Card.new()
      card_id = card.idnum
      id = card.user_id(card_id)
      card.pasori.close
      card.felica.close
    else
      card_id = STDIN.gets.to_s.chomp
      id = Card::debug(card_id)
    end

    # idが既にある場合（登録済み）
    if id
      user = BotUser.new(id:id)
      staytus = user.staytus?
      time = Time.now + 60*60*9

      if !staytus
        user.entrance(time)
        text = Function.in(id:id)
        oebot.post(text) if text
      else
        user.exit(time)
        staying_time = time_to_str(Condition.sum_time(id:id))
        text = Function.out(id:id,staying_time:staying_time)
        oebot.post(text) if text
      end

    # idが見つからない場合（未登録）
    else
      loop do
        puts "（☝◞‸◟）☝ あなたはまだ登録されていません"
        print "ฅ(๑'Δ'๑) 登録しますか(y/n)? :"
        input = STDIN.gets.to_s.chomp

        if input == "y" || input == "Y"
          to_entry(oebot,card_id,debug)
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
