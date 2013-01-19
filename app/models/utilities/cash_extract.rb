# coding: utf-8

require 'pdf_document/cash'


module Utilities
#
# un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
# se créé en appelant new avec un book et une date quelconque du mois souhaité
#
#
class CashExtract < InOutExtract

  # définit les titres des colonnes
  def titles
    ['Date', 'Réf', 'Libellé', 'Destination', 'Nature', 'Sorties', 'Entrées']
  end


  # pour pouvoir utiliser indifféremment cash ou book car il n'est pas forcément
  # facile de penser à écrire book quand on traite d'un CashExtract
  def cash
    @book
  end

  # pour une caisse, les lignes sont obtenues par une relation has_many :lines,
  # :through=>:accounts
  def lines
    @lines ||= cash.compta_lines.extract(@begin_date, @end_date)
  end

  # produit le document pdf en s'appuyant sur la classe PdfDocument::Book
  def to_pdf

      pdf = PdfDocument::Cash.new(@period, @book, options_for_pdf)
      pdf.set_columns ['writings.date AS w_date', 'writings.ref AS w_ref',
        'writings.narration AS w_narration', 'destination_id',
        'nature_id', 'credit', 'debit']
      pdf.set_columns_methods ['writing.date', 'writing.ref', 'writing.narration',
        'destination_id.name', 'nature_id.name', 'credit', 'debit']
      pdf.set_columns_titles(titles)
      pdf.set_columns_widths([12, 12, 28,12,12,12,12])
      pdf.set_columns_to_totalize [5,6]

      pdf
  end

  
  protected

  
  # ce prepare_line prépare les lignes pour les exports en csv et xls
  #
  # ne pas le confondre avec celui qui préparer les lignes pour le pdf
  # et qui se situe dans la classe PdfDocument::Cash
  def prepare_line(line)
    
    [I18n::l(line.line_date),
       line.ref,
       line.narration.truncate(40),
       line.destination ? line.destination.name.truncate(22) : '-',
       line.nature ? line.nature.name.truncate(22) : '-' ,
      reformat(line.credit),
      reformat(line.debit)]
  end




end
  

end
