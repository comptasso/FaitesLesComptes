# coding: utf-8

# Classe destinée à imprimer les tables de lignes. Listing est construit
# à partir d'un exercice, d'un mois au sein de cet exercice et d'un livre
#
# TODO ceci ressemble très fort à MonthlyBookExtract, factorisation ?
require 'month_year'

class Listing
  NB_PER_PAGE=30

  attr_reader :lines

  def initialize(book,  month, year)
    @book = book
    @organism = @book.organism
    my = MonthYear.new(month:month, year:year)
    @lines = @book.lines.monthyear(my).order(:line_date).all
  end

  # calcule le nombre de page du listing en divisant le nombre de lignes
  # par un float qui est le nombre de lignes par pages,
  # puis arrondi au nombre supérieur
  def total_pages
    (@lines.count/NB_PER_PAGE.to_f).ceil
  end

  # renvoie les lignes correspondant à la page demandée
  def page(n)
    n = n-1 # pour partir d'une numérotation à zero
    return nil if n > self.total_pages
    @lines[(NB_PER_PAGE*n)..(NB_PER_PAGE*(n+1)-1)].map do |item|
      [
        item.line_date,
        item.ref,
        item.narration.truncate(40),
        item.nature ? item.nature.name.truncate(22) : '-' ,
        item.destination ? item.destination.name.truncate(22) : '-',
        item.debit,
        item.credit
      ]
    end
  end

  def debit_before
    @book.lines.cumul_period_month(@period,@month).sum(:debit)
  end

  def credit_before
    @book.lines.cumul_period_month(@period,@month).sum(:credit)
  end

  def total_debit
    @lines.sum(&:debit)
  end

   def total_credit
    @lines.sum(&:credit)
  end

   # indique si le listing doit être considéré comme un brouillard
   # ou une édition définitive.
   #
   # Cela se fait en regardant si toutes les lignes sont locked?
   #
   # TODO attention avec les livres virtuels tels que CashBook
   # il faut peut être que transfer ait un champ locked?
   def brouillard?
     if @lines.any? {|l| !l.locked? }
       return true
     else
       return false
     end
   end

end

