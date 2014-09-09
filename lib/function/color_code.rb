#coding:utf-8

# 抵抗値 -> カラーコード
def c_encode(ohm_str)

  color = {"黒" => 0,"茶" => 1,"赤" => 2,"橙" => 3,"黄" => 4,"緑" => 5,"青" => 6,"紫" => 7,"灰" => 8,"白" => 9,"金" => -1,"銀" => -2}
  range = {"茶" => 1,"赤" => 2,"緑" => 0.5,"青" => 0.25,"紫" => 0.1,"橙" => 0.05,"金" => 5,"銀" => 10,"" => 20}

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

  # ohm[0]が抵抗値でohm[1]が誤差となる
  ohm = ohm_str.split(",")
  ans = Array.new
  error = false

  ohm[0] = ohm[0].to_f
  ohm[1] = ohm[1].to_f

  # 誤差が指定されなかったら(nilであったらto_fメソッドで0.0に)
  if ohm[1] == 0.0
    ans[3] = ""
  # 指定されていてもそれがrangeの値にないものだったら
  elsif !range.key(ohm[1])
    ans[3] = ""
  else
    ans[3] = range.key(ohm[1])
  end

  if ohm_str =~ /(k|K|ｋ|キロ)/
    ohm[0] *= 1000
  elsif ohm_str =~ /(m|M|ｍ|メガ)/
    ohm[0] *= 1000000
  end

  digits_num = ohm[0].to_s.length - 2
  if !color.key(digits_num)
    error = true
  end

  if !error then
    if digits_num >2
      ohm[0] = ohm[0]/(10**(digits_num-2))
      ohm[0] = ohm[0].to_i
      ans[0] = color.key(ohm[0]/10)
      ans[1] = color.key(ohm[0] - (ohm[0]/10)*10)
      ans[2] = color.key(digits_num - 2)
      return "#{ans[0]}#{ans[1]}#{ans[2]}#{ans[3]}"
    else
      ohm[0] = ohm[0].to_i
      ans[0] = color.key(ohm[0]/10)
      ans[1] = color.key(ohm[0] - (ohm[0]/10)*10)
      ans[2] = color.key(0)
      return "#{ans[0]}#{ans[1]}#{ans[2]}#{ans[3]}"
    end
  else
    time = Time.now.strftime("[%Y-%m-%d %H:%M]")
    return "errorです。\n#{time}"
  end

end

# カラーコード -> 抵抗値
def c_decode(code)

  color = {"黒" => 0,"茶" => 1,"赤" => 2,"橙" => 3,"黄" => 4,"緑" => 5,"青" => 6,"紫" => 7,"灰" => 8,"白" => 9,"金" => -1,"銀" => -2}
  range = {"茶" => 1,"赤" => 2,"緑" => 0.5,"青" => 0.25,"紫" => 0.1,"橙" => 0.05,"金" => 5,"銀" => 10}

  digits = code.split("")

  error = false

  # 文字数が3か4のものだけ受け付ける
  if digits.size < 3 || digits.size > 4
    error = true
  end

  # 上記にない色や漢字が送られてきたら
  digits.each{ |digit|
    if !color[digit]
      error = true
    end
  }

  # もし数値のところに金、銀がきたら
  if color[digits[0]] < 0 || color[digits[1]] < 0
    error = true
  # 誤差のところに変な色がきたら(空白はOK)
  elsif digits[3] && !range[digits[3]]
    error = true
  end

  range_str = ""
  if digits.size == 4
    range_str = "±#{range[digits[3]]}％"
  else
    range_str = "±20％"
  end

  if !error then
    ohm = 0.0
    ohm += color[digits[0]] * 10
    ohm += color[digits[1]]
    # 浮動小数点の小数第3位を四捨五入する
    ohm = sprintf("%.2f",ohm*(10**color[digits[2]])).to_f
    digits_num = ohm.to_s.length - 2
    if digits_num >= 4 && digits_num < 7
      ohm = ohm/1000
      # 2.2kΩとかはそのままで10.0Ωとかを10Ωにする
      ohm = ohm.to_s.gsub(/\.0/,"")
      return "#{ohm}kΩ #{range_str}"
    elsif digits_num >= 7
      ohm = ohm/1000000
      ohm = ohm.to_s.gsub(/\.0/,"")
      return "#{ohm}MΩ #{range_str}"
    # 例えば0.01が01になるのを防ぐ(0.0は0に)
    elsif ohm != 0.0 && ohm < 0.1
      return "#{ohm}Ω #{range_str}"
    else
      ohm = ohm.to_s.gsub(/\.0/,"")
      return "#{ohm}Ω #{range_str}"
    end
  else
    time = Time.now.strftime("[%Y-%m-%d %H:%M]")
    return "errorです。\n#{time}"
  end

end
