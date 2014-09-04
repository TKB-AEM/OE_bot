# coding:utf-8

# 分単位の値を渡すと日、時間、分で換算して文字列として返す
# time_to_str(data.sum_time(id))
# time_to_str(User.find(id).condition.staying_time)
def time_to_str(min)
  if min < 60
    return "#{min}分"

  elsif min < 60*24
    hour = (min/60).to_i
    min = min - hour*60
    if min == 0
      return "#{hour}時間"
    else
      return "#{hour}時間#{min}分"
    end

  else
    day = (min/(60*24)).to_i
    hour = ((min - day*24*60)/60).to_i
    if hour == 0
      hour_str = ""
    else
      hour_str = "#{hour}時間"
    end
    min = min - day*24*60 -hour*60
    if min == 0
      min_str = ""
    else
      min_str = "#{min}分"
    end
    return "#{day}日と" + hour_str + min_str
  end
end
