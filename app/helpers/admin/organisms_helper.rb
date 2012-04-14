# coding: utf-8

module Admin::OrganismsHelper

   # admin_menu books prend une chaine de caractère représentant un modèle
   # et crée les entrées Afficher et Nouveau

  def admin_menu(model)
    content_tag(:ul, :class=>"dropdown-menu") do
      content_tag(:li) { link_to 'Afficher', eval("admin_organism_#{model.pluralize}_path(@organism)") } +
      content_tag(:li) {link_to 'Nouveau', eval("new_admin_organism_#{model}_path(@organism)") }
    end
  end
  
 


end