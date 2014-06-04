# coding: utf-8

module Admin::MenusHelper
  
  # admin_menu model prend une chaine de caractère représentant un modèle
  # et crée les entrées Afficher et Nouveau
  #
  def admin_menu(model)
    content_tag(:ul, :class=>"dropdown-menu") do
      content_tag(:li) { link_to 'Afficher', url_for(controller:"admin/#{model.pluralize}", action:'index', organism_id:@organism.id) } +
      content_tag(:li) {link_to 'Nouveau', url_for(controller:"admin/#{model.pluralize}", action:'new', organism_id:@organism.id) }
    end
  end
  
  # sous menu avec un title intermédiaire
  def admin_sub_menu(title, model)
   content_tag(:li, class:"nav-header no-link") { link_to(title, '#')} + 
   content_tag(:li) { link_to 'Afficher', url_for(controller:"admin/#{model.pluralize}", action:'index', organism_id:@organism.id) } +
   content_tag(:li) {link_to 'Nouveau', url_for(controller:"admin/#{model.pluralize}", action:'new', organism_id:@organism.id) }
  end
  
  # menu avec juste l'affichage, mais pas de lien nouveau
   def admin_afficher(model)
    content_tag(:ul, :class=>"dropdown-menu") do
      content_tag(:li) { link_to 'Afficher', url_for(controller:"admin/#{model.pluralize}", action:'index', organism_id:@organism.id) }
    end
  end
  
  
end
