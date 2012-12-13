# coding: utf-8
module Utilities
#
# un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
# se créé en appelant new avec un book et une date quelconque du mois souhaité
#
#
class CashExtract < InOutExtract

  def initialize(cash, period)
      @titles = ['Date', 'Réf', 'Libellé', 'Destination', 'Nature', 'Sorties', 'Entrées']
      @book = cash
      @period = period
    end


  # pour pouvoir utiliser indifféremment cash ou book car il n'est pas forcément
  # facile de penser à écrire book quand on traite d'un CashExtract
  def cash
    @book
  end

  # pour une caisse, les lignes sont obtenues par une relation has_many :lines,
  # :through=>:accounts
  def lines
    @lines ||= cash.compta_lines.range_date(@period.start_date, @period.close_date)
  end

  
  protected

  

  def prepare_line(line)
    [I18n::l(line.line_date),
       line.ref, line.narration.truncate(40),
       line.destination ? line.destination.name.truncate(22) : '-',
       line.nature ? line.nature.name.truncate(22) : '-' ,
      reformat(line.credit),
      reformat(line.debit)]
  end




end
  

end
