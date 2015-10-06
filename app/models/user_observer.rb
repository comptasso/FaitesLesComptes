# coding: utf-8

class UserObserver < ActiveRecord::Observer

  # Voir les instructions de DelayedJob pour Rails 3 sur cette curieuse approche
  # mais deliver est bien effectué par delay.
  #
  # Envoi du mail vars l'administrateur de la base indiquant qu'un nouvel
  # utilisateur s'est inscrit
  #
  def after_create(user)
    UserInscription.delay.new_user_advice(user)
  end

end
