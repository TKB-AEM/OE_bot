# coding: utf-8

module OEbot
  class Function

    include Etcetera
    include Oruka
    include ColorCode

    attr_accessor :rep_table

    def initialize(table, buns_list)
      @rep_table = table
      @buns_list = buns_list
      @e24_series = { 1=>[0, 1, 2, 3, 5, 6, 8],
                      2=>[0, 2, 4, 7],
                      3=>[0, 3, 6, 9],
                      4=>[3, 7],
                      5=>[1, 6],
                      6=>[2, 8],
                      7=>[5],
                      8=>[2],
                      9=>[1] }
      @color = { "黒" => 0,"茶" => 1,"赤" => 2,"橙" => 3,"黄" => 4,"緑" => 5,"青" => 6,"紫" => 7,"灰" => 8,"白" => 9,
                 "金" => -1,"銀" => -2 }
      @range = { "茶" => 1,"赤" => 2,"緑" => 0.5,"青" => 0.25,"紫" => 0.1,"橙" => 0.05,
                 "金" => 5,"銀" => 10,"" => 20 }
    end
  end
end
