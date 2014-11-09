# coding: utf-8

module OEbot
  module ColorCode

    attr_accessor :color, :range, :e24_series

    def encode_filter(ohm_str)
      ohm_str = ohm_str.gsub(/(Ω|オーム|\s|　)/,"")
      ohm_str = ohm_str.gsub(/０/,"0")
      ohm_str = ohm_str.gsub(/１/,"1")
      ohm_str = ohm_str.gsub(/２/,"2")
      ohm_str = ohm_str.gsub(/３/,"3")
      ohm_str = ohm_str.gsub(/４/,"4")
      ohm_str = ohm_str.gsub(/５/,"5")
      ohm_str = ohm_str.gsub(/６/,"6")
      ohm_str = ohm_str.gsub(/７/,"7")
      ohm_str = ohm_str.gsub(/８/,"8")
      ohm_str = ohm_str.gsub(/９/,"9")
      ohm_str = ohm_str.gsub(/(％|%|㌫|ぱーせんと|パーセント|ﾊﾟｰｾﾝﾄ)/,"")
      ohm_str = ohm_str.gsub(/(±|プラスマイナス|ぷらすまいなす|プラマイ|ぷらまい)/,",")
      ohm = ohm_str.split(",")
      return if ohm[0].nil?

      # 誤差指定の省略は可能
      # また、"K"、"メガ"などはnumber?の判定で弾かれるので一時的にエスケープ
      if ohm[1].nil?
        return ohm_str if ohm[0].gsub(/(k|K|ｋ|キロ|m|M|ｍ|メガ)/,"").number?
      else
        return ohm_str if ohm[0].gsub(/(k|K|ｋ|キロ|m|M|ｍ|メガ)/,"").number? && ohm[1].number?
      end
      return
    end

    def decode_filter(code)
      code = code.gsub(/(\s|　|,|、)/,"")
      code.split("").each do |color|
        return unless color =~ /(黒|茶|赤|橙|黄|緑|青|紫|灰|白|金|銀)/
      end
      return code
    end

    # E24系列であるかどうか
    def e24?(*digits)
      return false unless digits.size == 2
      @e24_series.each do |key, val|
        if digits[0] == key
          return true if val.any? { |v| v == digits[1] }
        end
      end
      return false
    end

    # 抵抗値 -> カラーコード
    def encode(ohm_str)
      ohm_str = encode_filter(ohm_str)
      return if ohm_str.nil?

      # ohm[0]が抵抗値でohm[1]が誤差となる
      ohm = ohm_str.split(",")
      ans = Array.new
      error = false

      ohm[0] = ohm[0].to_f
      ohm[1] = ohm[1].to_f

      # 誤差が指定されなかったら(nilであったらto_fメソッドで0.0に)
      # 指定されていてもそれが@rangeの値にないものだったら
      ans[3] = "" if ohm[1] == 0.0 || !@range.key(ohm[1])
      ans[3] ||= @range.key(ohm[1])

      case(ohm_str)
      when /(k|K|ｋ|キロ)/ then ohm[0] *= 1000
      when /(m|M|ｍ|メガ)/ then ohm[0] *= 1000000
      end

      digits_num = ohm[0].to_s.length - 2
      error = true if !@color.key(digits_num) || ohm[0].to_s =~ /e/

      if !error then
        # 2桁以上の抵抗（0.01とかがdigits_num == 2なので回避）
        if digits_num > 1 && ohm[0] > 1
          ohm[0] = ohm[0]/(10**(digits_num-2))
          ohm[0] = ohm[0].to_i
          ans[0] = @color.key(ohm[0]/10)
          ans[1] = @color.key(ohm[0] - (ohm[0]/10)*10)
          ans[2] = @color.key(digits_num - 2)
          ans_str = "#{ans[0]}#{ans[1]}#{ans[2]}#{ans[3]}"

        # 1桁の抵抗
        elsif digits_num == 1 && ohm[0] >= 1
          ans[0] = @color.key(ohm[0].to_i)
          ohm[0] = (ohm[0]*10).to_i
          ans[1] = @color.key(ohm[0] - (ohm[0]/10)*10)
          ans[2] = @color.key(-1)
          ans_str = "#{ans[0]}#{ans[1]}#{ans[2]}#{ans[3]}"

        # 0.1以上で1より小さい抵抗
        elsif 0.1 <= ohm[0] && ohm[0] < 1
          ans[0] = @color.key((ohm[0]*10).to_i)
          ohm[0] = (ohm[0]*100).to_i
          ans[1] = @color.key(ohm[0] - (ohm[0]/10)*10)
          ans[2] = @color.key(-2)
          ans_str = "#{ans[0]}#{ans[1]}#{ans[2]}#{ans[3]}"

        elsif ohm[0] == 0.0
          ans_str = "黒"
        else
          ans_str = "それめっちゃ小さくないですか。"
        end
      end

      if ans[0]
        ans_str += "\n(※E24系列の抵抗値ではないです)" unless e24?(@color[ans[0]], @color[ans[1]])
      end
      ans_str ||= "そんな抵抗ないです。"
      return ans_str
    end

    # カラーコード -> 抵抗値
    def decode(code)
      code = decode_filter(code)
      return if code.nil?

      digits = code.split("")
      ans = nil

      ans = case code
      when /^黒$/                 then "0Ω"
      when /^黒{3}.?$/, /^黒{2}$/ then "0Ωは黒一本です。"
      end

      catch(:error) do
        throw :error if code.match(/^黒{3}.?$/) || code.match(/^黒{2}$/)

        # 文字数が3か4のものだけ受け付ける
        throw :error if digits.size < 3 || digits.size > 4
        return "一本目に黒はないです。" if digits[0] == "黒"

        # 上記にない色や漢字が送られてきたら
        digits.each{ |digit| throw :error unless @color[digit] }

        # もし数値のところに金、銀がきたら
        throw :error if @color[digits[0]] < 0 || @color[digits[1]] < 0

        # 誤差のところに変な色がきたら(空白はOK)
        throw :error if digits[3] && !@range[digits[3]]

        range_str = "±#{@range[digits[3]]}％" if digits.size == 4
        range_str ||= ""

        ohm = 0.0
        ohm += @color[digits[0]] * 10
        ohm += @color[digits[1]]
        # 浮動小数点の小数第3位を四捨五入する
        ohm = sprintf("%.2f",ohm*(10**@color[digits[2]])).to_f
        digits_num = ohm.to_s.length - 2

        if digits_num >= 4 && digits_num < 7
          ohm = ohm/1000
          # 2.2kΩとかはそのままで10.0Ωとかを10Ωにする
          ohm = ohm.to_s.gsub(/\.0/,"")
          ans ||= "#{ohm}kΩ #{range_str}"

        elsif digits_num >= 7
          ohm = ohm/1000000
          ohm = ohm.to_s.gsub(/\.0/,"")
          ans ||= "#{ohm}MΩ #{range_str}"
          ans += "\nですが値が大き過ぎます。" if digits_num > 8

        # 例えば0.01が01になるのを防ぐ(0.0は0に)
        elsif ohm != 0.0 && ohm < 0.1
          ans ||= "#{ohm}Ω #{range_str}"

        else
          ohm = ohm.to_s.gsub(/\.0/,"")
          ans ||= "#{ohm}Ω #{range_str}"
        end
        ans += "\n(※E24系列の抵抗値ではないです)" unless e24?(@color[digits[0]], @color[digits[1]])
      end

      ans ||= "そんな抵抗ないです。"
      return ans
    end

  end
end