# coding: utf-8

class DeviseRegistrationsController < Devise::RegistrationsController
   protected
      def after_inactive_sign_up_path_for(user)
        devise_registrations_waitingconfirmation_url
      end
end

