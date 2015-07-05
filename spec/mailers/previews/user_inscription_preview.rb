class UserInscriptionPreview < ActionMailer::Preview
  def welcome_user
    UserInscription.welcome_user(User.first)
  end
  
  def new_user_advice
    UserInscription.new_user_advice(User.first)
  end
end