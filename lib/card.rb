# coding:utf-8

require 'pasori'
require_relative "./function/function.rb"

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
    user = User.find_by_card_id(card_id)
    if !(user)
      return false
    else
      id = user.id
      return id
    end
  end

end