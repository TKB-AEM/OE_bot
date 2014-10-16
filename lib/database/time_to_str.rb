# coding:utf-8

# 分単位の値を渡すと日、時間、分で換算して文字列として返す
# time_to_str(data.sum_time(id))
# time_to_str(User.find(id).condition.staying_time)
def time_to_str(min)

  if min < 60
    ans = "#{min}分"

  elsif min < 60*24
    hour = (min/60).to_i
    min = min - hour*60
    ans = "#{hour}時間" if min == 0
    ans ||= "#{hour}時間#{min}分"

  else
    day = (min/(60*24)).to_i
    hour = ((min - day*24*60)/60).to_i
    hour_str = "" if hour == 0
    hour_str ||= "#{hour}時間"

    min = min - day*24*60 -hour*60
    min_str = "" if min == 0
    min_str ||= "#{min}分"

    day_str = "#{day}日" if hour_str.empty? && min_str.empty?
    day_str ||= "#{day}日と"
    ans = day_str + hour_str + min_str
  end

  return ans
end
