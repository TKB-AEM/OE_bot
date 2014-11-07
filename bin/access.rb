#!/usr/bin/env ruby
# coding: utf-8

require "../lib/oebot"

debug = false
pasori = true
OptionParser.new do |opt|
  opt.on('-d', '--debug','Switch to debug mode'){|v| debug = v}
  opt.on('--[no-]pasori','Select whether to use PaSoRi or not'){|v| pasori = v}
  opt.parse!(ARGV)
end

oebot = OEbot::Bot.new(debug:debug)

begin
  loop do
    system("clear")
    puts "debug mode" if debug

    puts "ฅ(๑'Δ'๑) カードを置いてください。"

    # PaSoRiがない場合番号を手動入力する
    if pasori
      card = OEbot::Card.new()
      card_id = card.idnum
      id = card.user_id(card_id)
      card.pasori.close
      card.felica.close
    else
      card_id = STDIN.gets.to_s.chomp
      id = OEbot::Card.debug(card_id)
    end

    # idが既にある場合（登録済み）
    if id
      user = OEbot::DataBase.new(id:id)
      staytus = user.staytus?
      time = Time.now + 60*60*9

      if staytus
        user.exit(time)
        staying_time = user.cal_stayingtime.minutes_to_s
        text = OEbot::Oruka.out(id, staying_time)
        oebot.post(text) if text
      else
        user.entrance(time)
        text = OEbot::Oruka.in(id)
        oebot.post(text) if text
      end

    # idが見つからない場合（未登録）
    else
      loop do
        puts "（☝◞‸◟）☝ あなたはまだ登録されていません"
        print "ฅ(๑'Δ'๑) 登録しますか(y/n)? :"
        input = STDIN.gets.to_s.chomp

        case input
        when /y/i
          OEbot.sign_up(oebot, card_id:card_id)
          break
        when /n/i
          break
        else
          system("clear")
          puts "(๑¯Δ¯๑)/ もういちど入力してください。\n\n"
          redo
        end
      end
    end

    sleep 4
  end

rescue Interrupt
  exit 1
rescue
  error_logs("access", $!, $@)
  sleep 3
  retry
end
