# coding: utf-8

# Classe destinée à imprimer les tables de lignes. Listing est construit
# à partir d'une collection de lignes, appartenant à un mois et un exercice
#
class Listing
  NB_PER_PAGE=25

  def initialize(period, month, book)
    @organism=period.organism
    @period=period
    @month=month
    @book=book
    @lines = @book.lines.period_month(@period, @month).all
  end

  # calcule le nombre de page du listing
  def total_pages
    @lines.size/NB_PER_PAGE
  end

  # renvoie les lignes correspondant à la page demandée
  def page(n)
    n=n-1 # pour partir d'une numérotation à zero
    return nil if n > self.total_pages
    @lines[(NB_PER_PAGE*n)..(NB_PER_PAGE*(n+1)-1)].map do |item|
      [
        I18n::l(item.line_date),
        item.narration,
        item.nature ? item.nature.name : '-' ,
        item.destination ? item.destination.name : '-',
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

end

