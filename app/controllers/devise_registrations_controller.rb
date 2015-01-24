# coding: utf-8

class DeviseRegistrationsController < Devise::RegistrationsController
  # rajouté suite au passage à Rails 4
  before_filter :configure_permitted_parameters

  protected

  # my custom fields are :name, :heard_how
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :email, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:name,:email, :password, :password_confirmation, :current_password)
    end
  end
  
   
  def after_inactive_sign_up_path_for(user)
    devise_registrations_waitingconfirmation_url
  end
end

