# coding: utf-8

module Extract
#
# un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
# 
#
class Cash < Extract::InOut
  
  # définit les titres des colonnes
  # 
  # en cas de modification, ne pas oublier de vérifier l'incidence sur les 
  # éditions pdf.
  def titles
    ['Date', 'Pièce', 'Réf', 'Libellé', 'Activité', 'Nature', 'Sorties', 'Entrées']
  end
  
  def title
    "Livre de caisse : #{book.title}"
  end


  # pour pouvoir utiliser indifféremment cash ou book car il n'est pas forcément
  # facile de penser à écrire book quand on traite d'un CashExtract
  def cash
    @book
  end

#  # remplit les lignes de l'extrait
#  def lines
#    @lines ||= cash.extract_lines(from_date, to_date)
#  end
  
  alias compta_lines lines

  # produit le document pdf en s'appuyant sur la classe PdfDocument::Book
  def to_pdf
     Editions::Cash.new(@period, self)
  end

  
  protected

  
  # ce prepare_line prépare les lignes pour les exports en csv et xls
  #
  # ne pas le confondre avec celui qui préparer les lignes pour le pdf
  # et qui se situe dans la classe Editions::Cash
  def prepare_line(line)
    
    [I18n::l(line.date),
       line.piece_number,
       line.ref,
       line.narration.truncate(40),
       line.destination ? line.destination.name.truncate(22) : '-',
       line.nature ? line.nature.name.truncate(22) : '-' ,
      french_format(line.credit),
      french_format(line.debit)]
  end




end
  

end
