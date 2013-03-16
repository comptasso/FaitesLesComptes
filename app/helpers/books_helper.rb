module BooksHelper
  
  # Pour l'affichage d'une liste de mois dans les différentes vues avec des lignes
  # telles que les livres, les caisses,...
  # 
  # Les arguments sont period (l'exercice), un hash reprenant les options nécessaires, 
  # en l'occurence, l'action, le controller, et les arguments complémentaires éventuels.
  # 
  # Un argument optionnel booleen indique si on veut que le lien 'tous' soit présent.
  # Par exemple, pour les livres c'est souhaitable, mais pour les contrôles de caisse
  # normalement tous les jours, ce n'est pas forcément idéal.
  # 
  # Exemple submenu_mois(@period, {action:'index', controller:'cash_controls', :cash_id=>@cash.id}, false)
  # pour afficher les mois et renvoyer vers les contrôles de caisse.
  # 
  # On aura comme affichage les liens jan fév mar... chacun pointant vers l'action voulue
  # 
  #
  def submenu_mois(period, opt, all = true)
    plm = period.list_months.collect do |m|
    content_tag :li , :class=>'active' do 
      link_to_unless_current(m.to_short, url_for(opt.merge({:mois=>m.month, :an=>m.year})))
    end
    end
    if all
      tous = content_tag :li, :class=>'active' do
       link_to_unless_current('tous', url_for(opt.merge({:mois=>'tous'})))
      end
    plm.append tous
    end
    plm.join.html_safe
  end
  
  
  
end
