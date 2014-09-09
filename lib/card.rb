# coding:utf-8

require 'pasori'
require_relative "./function/function.rb"

class Card

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

  # カードのIDを渡すとユーザーのidを返す
  def check(card_id = "")
    user = User.find_by_card_id(card_id)

    if !(user)
      return false
    else
      id = user.id
      return id
    end

  end

end
