# coding: utf-8

module OEbot
  module Etcetera

    attr_accessor :buns_list

    # OpenJTalkでしゃべらせる
    def say(contents)
      contents = contents.gsub(/@\w*/,"")
      contents = contents.sub(/(say|って言って|っていって)/i,"")
      contents = contents.gsub(/(\s|　|\(|\)|\||{|}|&|;|`|\$|emacs|rm|SHELL|irb)/,"")
      if !contents.empty? && !contents.nil?
        text = "「#{contents}」って言いました。"
        command = "paplay ./voice/ele.wav"
        system(command)
        command = "sh ../lib/oebot/function/mei/say.sh #{contents}"
        system(command)
      else
        text = "セリフを指定してください。"
      end
      return text
    end

    # L棟パンガチャ
    def gacha
      random = Random.new(Time.new.to_i)
      bun = @buns_list[random.rand(@buns_list.size)]
      text = "本日のL棟パンは#{bun}です。"
      return text
    end

    # どのキーワードにも当てはまらなかったら
    def conversation(contents)
      text = nil
      catch(:exit) do
        if contents.match(@rep_table['self'][0])
          text = @rep_table['self'][1].sample
          throw :exit
        end

        @rep_table['comprehensible'].each do |row|
          if row[0].any? {|keyword| contents.index(keyword) }
            text = row[1].sample
            throw :exit
          end
        end
      end

      text ||= @rep_table['incomprehensible'].sample
      return text
    end
  end
end