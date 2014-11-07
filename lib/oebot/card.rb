# coding: utf-8

module OEbot
  class Card

    attr_accessor :pasori , :felica

    def initialize
      @pasori = Pasori.open
    rescue PasoriError
      sleep 3
      retry
    end

    # カードのIDを返す
    def idnum
      @felica = @pasori.felica_polling(Felica::POLLING_ANY)
      idm = @felica.idm.unpack("C*").map{|c| sprintf("%02X",c)}.join.to_s
      return idm
      @felica.close
      @pasori.close
    rescue PasoriError
      sleep 3
      retry
    end

    # カードのIDを渡すとユーザーのidを返す
    def user_id(card_id = "")
      user = OEbot::User.find_by_card_id(card_id)
      id = nil
      id = user.id if user
      return id
    end

    def Card::debug(card_id = "")
      user = OEbot::User.find_by_card_id(card_id)
      id = nil
      id = user.id if user
      return id
    end
  end
end
