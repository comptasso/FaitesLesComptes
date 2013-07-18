# coding: utf-8

class UserObserver < ActiveRecord::Observer


  def after_create(user)
      message = UserInscription.new_user_advice(user)
      message.deliver
  end

end
