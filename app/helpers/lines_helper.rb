# -*- encoding : utf-8 -*-


module LinesHelper
    require 'csv'

  
 # consstruit une série de liens à partir des mois de l'exercice pour naviguer d'un mois
 # à l'autre
  def submenu_helper(book, mois, period )
    html = []
    content_tag :ul, class: "nav nav-pills mois offset3" do
        period.list_months('%b').each_with_index do |mois, i|
        html << content_tag(:li , :class=> "#{'active' if current_page?(:mois => i) }" ) { link_to_unless_current(mois, book_lines_path(book, "mois"=> i)) }
      end
     html << content_tag(:li) {icon_to('nouveau.png', new_book_line_path(book, mois: mois) ,id: 'new_line_link') }
    html.join('').html_safe
    end
     
  end

  # page est un tableau de lignes
  #  Cette méthode prend les différents éléments d'une page de listing, en l'occurence
  # les lignes de comptes et qui applique le helper debit_credit aux montants
  def prawn_prepare_page(page)
    page.each  {|l| l[0]=l l[0]; l[4]= debit_credit(l[4]); l[5]=debit_credit(l[5])}
   page.insert(0, ["Date", "Libellé", "Nature", "Destination", "Débit", "Crédit"])
  end




  def lines_to_csv
      CSV.generate do |csv|
      csv << ['Date', 'Libellé', 'Destination', 'Nature', 'Débit', 'Crédit', 'Paiement']
    @monthly_extract.lines.each do |line|
      csv << line.to_csv
    end
  end

  end


end
