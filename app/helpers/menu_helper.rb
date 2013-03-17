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
  # et crée les entrées Afficher et Nouveau.
  # 
  # opt permet de passer des options complémentaires comme organism:@organism
  # et ainsi d'avoir la possibilité de faire des routes composées.
  #
  def short_menu(model, opt = nil)
    options = {:controller=>model.pluralize}
    options = options.merge(opt) if opt
    content_tag(:ul, :class=>"dropdown-menu") do
      content_tag(:li) { link_to 'Afficher', url_for(options.merge({action:'index'})) } +
      content_tag(:li) {link_to 'Nouveau', url_for(options.merge({action:'new'})) }
    end
  end


  




  end
