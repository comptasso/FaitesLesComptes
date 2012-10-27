# coding: utf-8

require 'month_year' 

module Utilities


  # un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
  # se créé en appelant new avec un book et une date quelconque du mois souhaité
  # my_hash est un hash :year=>xxxx, :month=>yy
  class MonthlyInOutExtract

    NB_PER_PAGE=30

    attr_reader :book, :titles

    def initialize(book, my_hash)
      @titles = ['Date', 'Réf', 'Libellé', 'Destination', 'Nature', 'Débit', 'Crédit', 'Paiement', 'Support']
      @book = book
      @my = MonthYear.new(my_hash)
      @date = @my.beginning_of_month
    end

    def lines
      return @lines unless @lines == nil
      @lines ||= @book.compta_lines.mois(@date).in_out_lines
    end

    # calcule le nombre de page du listing en divisant le nombre de lignes
    # par un float qui est le nombre de lignes par pages,
    # puis arrondi au nombre supérieur
    def total_pages
      (lines.size/NB_PER_PAGE.to_f).ceil
    end

    def month
      @my.to_format('%B %Y')
    end

    # renvoie les lignes correspondant à la page demandée
    def page(n)
      n = n-1 # pour partir d'une numérotation à zero
      return nil if n > self.total_pages
      @lines[(NB_PER_PAGE*n)..(NB_PER_PAGE*(n+1)-1)].map do |item|
        prepare_line(item)
      end
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


    def to_csv(options)
      CSV.generate(options) do |csv|
        csv << @titles
        lines.each do |line|
          csv << prepare_line(line)
        end
      end
    end

    # to_xls est comme to_csv sauf qu'il y a un encodage en windows-1252
    def to_xls(options)
      CSV.generate(options) do |csv|
        csv << @titles.map {|data| data.encode("windows-1252")}
        lines.each do |line|
          csv << prepare_line(line).map { |data| data.encode("windows-1252") unless data.nil?}
        end
      end
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



    protected

    # prend une ligne comme argument et renvoie un array avec les différentes valeurs
    # préparées : date est gérée par I18n::l, les montants monétaires sont reformatés poru
    # avoir 2 décimales et une virgule,...
    def prepare_line(line)
      [I18n::l(line.line_date),
        line.ref, line.narration.truncate(25),
        line.destination ? line.destination.name.truncate(22) : '-',
        line.nature ? line.nature.name.truncate(22) : '-' ,
        reformat(line.debit),
        reformat(line.credit),
        "#{line.payment_mode}",
        line.support.truncate(10)
      ]
    end

 

    # remplace les points décimaux par des virgules pour s'adapter au paramétrage
    # des tableurs français
    def reformat(number)
      sprintf('%0.02f',number.to_s).gsub('.', ',')
    end


  

  end


end
