# coding:utf-8

# 分単位の値を渡すと日、時間、分で換算して文字列として返す
class Numeric
  def minutes_to_s

    if self < 60
      ans = "#{self}分"

    elsif self < 60*24
      hour = (self/60).to_i
      min = self - hour*60
      ans = "#{hour}時間" if min == 0
      ans ||= "#{hour}時間#{min}分"

    else
      day = (self/(60*24)).to_i
      hour = ((self - day*24*60)/60).to_i
      hour_str = "" if hour == 0
      hour_str ||= "#{hour}時間"

      min = self - day*24*60 -hour*60
      min_str = "" if min == 0
      min_str ||= "#{min}分"

      day_str = "#{day}日" if hour_str.empty? && min_str.empty?
      day_str ||= "#{day}日と"
      ans = day_str + hour_str + min_str
    end

    return ans
  end
end