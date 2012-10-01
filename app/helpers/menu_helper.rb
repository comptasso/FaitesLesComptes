# coding: utf-8

module MenuHelper

  def saisie_consult_organism_list
    rooms_with_period = current_user.rooms.select {|r| r.look_for { Organism.first.periods.any? } }
    lis = rooms_with_period.collect do |groom|
      content_tag :li ,link_to(groom.organism.title, room_path(groom))
    end
    lis.join('').html_safe
  end

  # menu prend une chaine de caractère représentant un modèle et
  # et crée les entrées Afficher et Nouveau en ayant des routes dépendant de @organism
  # Voir direct_menu pour avoir des routes non dépendantes
  def menu(model)
    content_tag(:ul, :class=>"dropdown-menu") do
      content_tag(:li) { link_to 'Afficher', eval("organism_#{model.pluralize}_path(@organism)") } +
      content_tag(:li) {link_to 'Nouveau', eval("new_organism_#{model}_path(@organism)") }
    end
  end


  # menu prend une chaine de caractère représentant un modèle et
  # et crée les entrées Afficher et Nouveau
  def direct_menu(model)
    content_tag(:ul, :class=>"dropdown-menu") do
      content_tag(:li) { link_to 'Afficher', eval("#{model.pluralize}_path") } +
      content_tag(:li) {link_to 'Nouveau', eval("new_#{model}_path") }
    end
  end




  end
