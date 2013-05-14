class Admin::ApplicationController < ApplicationController
  layout 'admin/layouts/application'

  protected


   # appelé par after_filter pour effacer les caches utilisés pour l'affichage
   # des menus
   def clear_org_cache
     Rails.cache.clear("saisie_#{current_user.name}")
     Rails.cache.clear("admin_#{current_user.name}")
     Rails.cache.clear("compta_#{current_user.name}")
   end
  
end
