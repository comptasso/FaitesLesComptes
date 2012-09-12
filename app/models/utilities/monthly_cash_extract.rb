# coding: utf-8
module Utilities
#
# un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
# se créé en appelant new avec un book et une date quelconque du mois souhaité
#
#
class MonthlyCashExtract < MonthlyBookExtract

  def initialize(cash, h)
    @titles = ['Date', 'Réf', 'Libellé', 'Destination', 'Nature', 'Débit', 'Crédit']
    @book = cash
    @my = MonthYear.new(h)
    @date = @my.beginning_of_month
  end

  # pour pouvoir utiliser indifféremment cash ou book car il n'est pas forcément
  # facile de penser à écrire book quand on traite d'un MonthlyCashExtract
  def cash
    @book
  end

  # pour une caisse, les lignes sont obtenues par une relation has_many :lines,
  # :through=>:accounts
  def lines
    @lines ||= cash.lines.mois(@date)
  end

  
  protected

  def prepare_line(line)
    [I18n::l(line.line_date),
       line.ref, line.narration.truncate(40),
       line.destination ? line.destination.name.truncate(22) : '-',
       line.nature ? line.nature.name.truncate(22) : '-' ,
      reformat(line.debit),
      reformat(line.credit)]
  end




end
  

end
