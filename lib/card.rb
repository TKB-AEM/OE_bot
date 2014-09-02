# coding:utf-8
require 'pasori'

class Card

  attr_accessor :hash

  def initialize
    @hash = Hash.new()
  end

  def Card::idnum
    card = new
    counts = 0
    loop do
      begin
        Pasori.open {|pasori|
          pasori.felica_polling {|felica|
            system = felica.request_system
            return card.dump_system_info(pasori, system)
          }
        }
        break
      rescue PasoriError
        sleep 2
      end
    end
  end

  def dump_id(felica)
    return felica.idm.unpack("C*").map{|c| sprintf("%02X", c)}.join
  end
  private :dump_id

  def dump_system_info(pasori, system)
    pasori.felica_polling(system[0]) {|felica|
      return dump_id(felica)
    }
  end

  # members.csv から番号と名前をハッシュに格納
  def reload
    File.open("../list/members.csv") do |io|
      io.each do |line|
        tmp = line.split(",",2)
        @hash[tmp[0].to_s] = tmp[1].chomp
      end
    end
  end

  # members.csv にないIDが読み込まれた場合、一次的に@hashにguestとして登録
  def reload_guest(num,guest)
    @hash[num] = guest
  end

  def hash(num = nil)
    return @hash[num]
  end

end
