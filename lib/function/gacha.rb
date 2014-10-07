# coding:utf-8

class Gacha

  attr_accessor :random

  def initialize(buns_list = [])
    @random = Random.new(Time.new.to_i)
    @grades = ["A+","A","B","C","D"]
    @buns = buns_list
  end

  def grades_gacha()
    rarity = @random.rand(101)
    if rarity > 95
      return @grades[0]
    elsif rarity > 80 && rarity <= 95
      return @grades[1]
    elsif rarity > 60 && rarity <= 80
      return @grades[2]
    elsif rarity > 30 && rarity <= 60
      return @grades[3]
    elsif rarity > -1 && rarity <= 30
      return @grades[4]
    else 
      return "error"
    end
  end

  def buns_gacha()
    return @buns[@random.rand(@buns.size)]
  end

end
