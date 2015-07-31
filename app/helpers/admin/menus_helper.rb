# coding: utf-8

module Admin::MenusHelper

  # admin_menu model prend une chaine de caractère représentant un modèle
  # et crée les entrées Afficher et Nouveau
  #
  def admin_menu(model)
    content_tag(:ul, class:'dropdown-menu', role:'menu') do
      content_tag(:li, role:'presentation') do
        link_to 'Afficher',
          url_for(controller:"admin/#{model.pluralize}",
                  action:'index', organism_id:@organism.id),
                  role:'menuitem'
      end+
      content_tag(:li, role:'presentation') do
        link_to 'Nouveau',
          url_for(controller:"admin/#{model.pluralize}",
                  action:'new', organism_id:@organism.id),
                  role:'menuitem'
      end
    end
  end

  # sous menu avec un title intermédiaire
  def admin_sub_menu(title, model)
    content_tag(:li, class:"dropdown-header no-link", role:'presentation') do
      link_to(title, '#', role:'menuitem')
    end +
    content_tag(:li, role:'presentation') do
      link_to 'Afficher',
        url_for(controller:"admin/#{model.pluralize}", action:'index', organism_id:@organism.id),
        role:'menuitem'
    end +
    content_tag(:li, role:'presentation') do
      link_to 'Nouveau',
        url_for(controller:"admin/#{model.pluralize}", action:'new', organism_id:@organism.id),
        role:'menuitem'
    end
  end

  # menu avec juste l'affichage, mais pas de lien nouveau
  def admin_afficher(model)
    content_tag(:ul, :class=>"dropdown-menu", role:'menu') do
      content_tag(:li, role:'presentation') do
        link_to 'Afficher',
          url_for(controller:"admin/#{model.pluralize}", action:'index', organism_id:@organism.id),
          role:'menuitem'
      end
    end
  end


end
