class UserInscription < ActionMailer::Base
  default :from=>'expert@faiteslescomptes.fr'

  def new_user_advice(user)
    @user = user
    mail(
      :to=>'expert@faiteslescomptes.fr',
      :subject=>'ouverture d\'un nouveau compte')
  end

end
