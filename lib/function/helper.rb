# coding: utf-8

# 整数か浮動小数点数であるならtrue
class String
  def number?
    Integer(self) unless self =~ /\./
    Float(self)
    true
   rescue ArgumentError
     false
  end
end
