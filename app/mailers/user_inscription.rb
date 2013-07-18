class UserInscription < ActionMailer::Base
  default :from=>'UserObserver'

  def new_user_advice(user)

    mail(
      :to=>'expert@faiteslescomptes.fr',
      :subject=>'ouverture d\'un nouveau compte',
      :from=>'UserObserver')
  end

end
