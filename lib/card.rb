# coding:utf-8

require 'pasori'
require_relative "./function/function.rb"

class Card

  # カードのIDを返す
  def Card::idnum
    pasori = Pasori.open
    loop do
      begin
        felica = pasori.felica_polling(Felica::POLLING_ANY)
        idm = felica.idm.unpack("C*").map{|c| sprintf("%02X",c)}.join.to_s
        felica.close
        pasori.close
        return idm
        break

      rescue PasoriError
        sleep 1
      end
    end
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
