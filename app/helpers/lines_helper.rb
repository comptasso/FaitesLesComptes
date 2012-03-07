# -*- encoding : utf-8 -*-


module LinesHelper
    require 'csv'

  def debit_credit(montant)
    if montant > -0.01 && montant < 0.01
      '-'
    else
      number_with_precision(montant, :precision=> 2)
    end
  rescue
    ''
  end

 
 # consstruit une série de liens à partir des mois de l'exercice pour naviguer d'un mois
 # à l'autre
  def submenu_helper(book, period)
     content_tag :span do
      s=''
       period.list_months('%b').each_with_index do |mois, i|
        s += concat(content_tag(:span) { link_to_unless_current(mois, book_lines_path(book, "mois"=> i)) })
      end
      s
    end
  end

  # page est un tableau de lignes
  #  Cette méthode prend les différents éléments d'une page de listing, en l'occurence
  # les lignes de comptes et qui applique le helper debit_credit aux montants
  def prawn_prepare_page(page)
    page.each  {|l| l[0]=l l[0]; l[4]= debit_credit(l[4]); l[5]=debit_credit(l[5])}
   page.insert(0, ["Date", "Narration", "Nature", "Destination", "Débit", "Crédit"])
  end




  def lines_to_csv
      CSV.generate do |csv|
      csv << ['Date', 'Libellé', 'Destination', 'Nature', 'Débit', 'Crédit', 'Paiement']
    @lines.each do |line|
      csv << line.to_csv
    end
  end

  end


end
