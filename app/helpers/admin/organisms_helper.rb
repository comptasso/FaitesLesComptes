# coding: utf-8

module Admin::OrganismsHelper

   # admin_menu books prend une chaine de caractère représentant un modèle
   # et crée les entrées Afficher et Nouveau

  def admin_menu(model)
    content_tag(:ul, :class=>"dropdown-menu") do
      content_tag(:li) { link_to 'Afficher', url_for(controller:"admin/#{model.pluralize}", action:'index', organism_id:@organism.id) } +
      content_tag(:li) {link_to 'Nouveau', url_for(controller:"admin/#{model.pluralize}", action:'new', organism_id:@organism.id) }
    end
  end
  
 


end