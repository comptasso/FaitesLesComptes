module BooksHelper
  
  # Pour l'affichage d'une liste de mois dans les différentes vues avec des lignes
  # telles que les livres, les caisses,...
  # 
  # Les arguments sont period (l'exercice), le MonthYear actuel, le path et un 
  # objet qui doit être transmis au path
  # ex submenu_mois(@period, my, 'cash_cash_lines_path', @cash)
  # 
  # On aura comme affichage les liens jan fév avr... chacun pointant vers l'action voulue
  # 
  #
  def submenu_mois(period, opt)
    plm = period.list_months.collect do |m|
    content_tag :li , :class=>'active' do 
      link_to_unless_current(m.to_short, url_for(opt.merge({:mois=>m.month, :an=>m.year})))
    end
    end
    tous = content_tag :li, :class=>'active' do
       link_to_unless_current('tous', url_for(opt.merge({:mois=>'tous'})))
      end
    plm.append tous
    plm.join.html_safe
  end
  
  
  
end
