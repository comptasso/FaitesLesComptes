# -*- encoding : utf-8 -*-

class Compta::ApplicationController < ApplicationController
  layout 'compta/layouts/application'

  before_filter :check_natures

  # vérifie que toutes les natures sont associées à un compte de l'exercice,
  # crée un flash[:alert]
  # TODO voir pour mettre ça dans un cache pour éviter la requête à chaque fois
  def check_natures
    if (@period)
      unless @period.all_natures_linked_to_account?
        flash[:alert]='Des natures ne sont pas reliées à des comptes'
      end
    end
  end
 
end
