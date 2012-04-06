# coding: utf-8

# un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
# se créé en appelant new avec un book et une date quelconque du mois souhaité
class Utilities::MonthlyBookExtract

  attr_reader :book

  def initialize(book, date)
    @book=book
    @date=date
  end

  def lines
    @book.lines.mois(@date)
  end

  def total_debit
    lines.sum(:debit)
  end
  
  def total_credit
    lines.sum(:credit)
  end

  def debit_before
    @book.cumulated_debit_before(@date)
  end

  def credit_before
    @book.cumulated_credit_before(@date)
  end

  def sold
    credit_before + total_credit - debit_before - total_debit
  end


  def to_csv
    CSV.generate do |csv|
      csv << ['Date', 'Libellé', 'Destination', 'Nature', 'Débit', 'Crédit', 'Paiement']
      lines.each do |line|
        csv << line.to_csv
      end
    end
  end


  

    #  def cumulated_debit_before(date)
    #    self.lines.where('line_date < ?', date).sum(:debit)
    #  end
    #  def cumulated_credit_before(date)
    #    self.lines.where('line_date < ?', date).sum(:credit)
    #  end
    #   def cumulated_debit_at(date)
    #    self.lines.where('line_date <= ?', date).sum(:debit)
    #  end
    #  def cumulated_credit_at(date)
    #    self.lines.where('line_date <= ?', date).sum(:credit)
    #  end


  end
