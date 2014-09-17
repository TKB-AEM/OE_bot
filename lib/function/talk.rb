#coding:utf-8

def talk(contents)
  # 挨拶
  if contents =~ /(ありがと|さんくす|Thank|thank|thx|Thx)/
    return "どういたしまして。"
  elsif contents =~ /(ただいま|きたく|帰宅)/
    return "おかえりなさい。"
  elsif contents =~ /(こんばんは|こんばんわ)/
    return "こんばんは。"
  elsif contents =~ /こんにちは/
    return "こんにちは。"
  elsif contents =~ /(おはよ|おきた|起きた)/
    return "おはようございます。"
  elsif contents =~ /(おやすみ|寝る|ねる|寝ます|ねます)/
    return "おやすみなさい。"

  # 返答
  elsif contents =~ /(本当|ホント|ほんとう|うそ|嘘)/
    return "パックは嘘を申しません。"
  elsif contents =~ /(Yo|yo|YO)/
    return "Yo!"
  elsif contents =~ /(ちっぱい|貧乳|ひんぬー|ひんにゅう)/
    return "フラットデザインです。"
  elsif contents =~ /おっぱい/
    return "そんなにおっぱいが好きなんですか。"
  elsif contents =~ /わかる/
    return "わかられました。"
  elsif contents =~ /それな/
    return "せやなです。"
  elsif contents =~ /せやな/
    return "それなです。"

  # その他
  elsif contents =~ /入室/
    return "部屋にきてください。"
  elsif contents =~ /リア充/
    return "みんな離れろ！リア充が爆発するぞ！"
  elsif contents =~ /(ようじょ|幼女)/
    return "私です。"
  elsif contents =~ /(進捗|しんちょく)/
    return "進捗どうですか。"
  elsif contents =~ /機能/
    return "https://github.com/TKB-AEM/OE_bot/blob/master/README.md"

  else
    wakaran = ["どう返してよいかわかりません。",
               "そんなこと言わないでください。",
               "その言葉はまだ理解できません。",
               "\n✌(’ω’)｡o(????????????)",
               "\n（ ˘⊖˘）。o(何言ってるんだこの人)",
               "\nわかります。（わからない顔）"]
    return wakaran.sample
  end
end
