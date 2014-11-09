# coding: utf-8

module OEbot
  module Oruka

    #
    # リプライに対する返答

    # ダレカオルカ
    def being
      members = ""
      last_id = OEbot::DataBase.last_id
      last_id.times do |id|
        id = id + 1
        user = OEbot::DataBase.new(id:id)
        if user.staytus?
          name = user.name
          members += name + ","
        end
      end
      text = "\n室内には\n#{members.chop} がいます。" if !(members.empty?)
      text ||= "\n室内には誰もいません。"
      return text
    rescue
      error_logs("おるか", $!, $@)
    end

    # 訪問回数と合計滞在時間を返す
    def record(twitter_id)
      if OEbot::DataBase.exist?(twitter_id:twitter_id)
        user = OEbot::DataBase.new(twitter_id:twitter_id)
        access_times = user.condition.access_times
        staying_time = (user.condition.staying_time).minutes_to_s
        text = "\nこれまでの訪問回数は#{access_times}回、\n合計滞在時間は#{staying_time}です。"
        members_num = OEbot::DataBase.last_id
        text += "\n滞在時間ランキング#{members_num}人中#{user.rank}位"
      else
        text = "3L502で登録してください。"
      end
      return text
    end

    # リプライで退室する
    def rep_exit(oebot, twitter_id)
      if OEbot::DataBase.exist?(twitter_id:twitter_id)
        user = OEbot::DataBase.new(twitter_id:twitter_id)
        if user.staytus?
          time = Time.now + 60*60*9
          user.exit(time)
          staying_time = (user.cal_stayingtime).minutes_to_s
          text = OEbot::Oruka.out(user.id, staying_time)
          oebot.post(text) if text
          text = "退室処理が完了しました。"
        else
          text = "あなたは部屋にいません。"
        end
      else
        text = "3L502で登録してください。"
      end
      return text
    end

    #
    # access.rb で使用される入退室時投稿の内容
    module_function

    # 入室
    def in(id)
      okaeri = ["okaeri1.wav","okaeri2.wav","okaeri3.wav","okaeri4.wav"]
      command = "paplay ./voice/#{okaeri.sample}"
      system(command)
      user = OEbot::DataBase.new(id:id)
      text = "#{user.name}が入室しました。"
      return text
    end

    # 退室
    def out(id,staying_time = "0分")
      command = "paplay ./voice/nyanpass.wav"
      system(command)
      user = OEbot::DataBase.new(id:id)
      text = "#{user.name}が退室しました。\n滞在時間は#{staying_time}です。"
      return text
    end
  end
end