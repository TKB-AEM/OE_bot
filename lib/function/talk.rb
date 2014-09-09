#coding:utf-8

def talk(contents)
  if contents =~ /(ありがと|さんくす|Thank)/
    return "どういたしまして。"
  elsif contents =~ /(本当|ホント|ほんとう|うそ|嘘)/
    return "パックは嘘を申しません。"
  elsif contents =~ /(おはよ|おきた|起きた)/
    return "おはようございます。"
  elsif contents =~ /(おやすみ|寝る|ねる|寝ます|ねます)/
    return "おやすみなさい。"
  elsif contents =~ /(Yo|yo|YO)/
    return "Yo!"
  elsif contents =~ /(ちっぱい|貧乳|ひんぬー|ひんにゅう)/
    return "フラットデザインです。"
  elsif contents =~ /(ただいま|きたく|帰宅)/
    return "おかえりなさい。"
  elsif contents =~ /わかる/
    return "わかられました。"
  elsif contents =~ /それな/
    return "せやなです。"
  elsif contents =~ /せやな/
    return "それなです。。"
  else
    wakaran = ["どう返してよいかわかりません。","そんなこと言わないでください。","その言葉はまだ理解できません。"]
    return wakaran.sample
  end
end
