# coding: utf-8

require 'month_year'

module Extract


  # un extrait d'un livre donné avec capacité à calculer les totaux et les soldes.
  # se crée avec deux paramètres : le livre et l'exercice.
  #
  # Cette classe est utilisée pour afficher les extraits de livre dans un mode
  # comptable, à savoir avec les données des writings et pour chaque writings
  # les compta_lines associées.
  #
  class Book < Extract::Base
    # utilities::sold définit les méthodes cumulated_debit_before(date) et
    # cumulated_debit_at(date) et les contreparties correspondantes.
    include Utilities::Sold

    include Utilities::ToCsv

    attr_reader :book, :titles, :from_date, :to_date

    def initialize(book, period, from_date = nil, to_date = nil )
      @book = book
      @period = period
      @from_date = from_date || period.start_date
      @to_date = to_date || period.close_date
    end

    # renvoie les titres des colonnes pour une édition ou un export
    #
    # utilisé par to_csv et to_xls et probablement aussi par to_pdf
    def titles
     %w(Date Pce Réf Libellé Compte Intitulé Débit Crédit)
    end

    def title
      book.title
    end

    def subtitle
      "Du #{I18n::l from_date} au #{I18n::l to_date}"
    end

    def lines
      @lines ||= @book.compta_lines.includes(:writing, :account).
        where('date >= ? AND date <= ?', from_date, to_date)
    end

    alias compta_lines lines

    # l'extrait est provisoire si il y a des lignes qui ne sont pas verrouillées
    def provisoire?
      lines.reject {|l| l.locked?}.any?
    end

    def cumulated_at(date, dc)
      @book.cumulated_at(date, dc)
    end

    def debit_before
      super(from_date)
    end

    def credit_before
      super(from_date)
    end

    def to_csv(options = {:col_sep=>"\t"})
      CSV.generate(options) do |csv|
        csv << titles
        lines.each do |line|
          csv << prepare_line(line)
        end
      end
    end
    
      

    # produit le document pdf en s'appuyant sur la classe Editions::Book
    def to_pdf      
      Editions::Book.new(@period, self)
    end

    protected

  
    
    #  Utilisé pour l'export vers le csv et le xls
    # 
    # Prend une ligne comme argument et renvoie un array avec les différentes valeurs
    # préparées : date est gérée par I18n::l, les montants monétaires sont reformatés poru
    # avoir 2 décimales et une virgule,...
    # 
    # On ne tronque pas les informations car celà est destiné à l'export vers un fichier csv ou xls
    # 
    def prepare_line(line)
      [I18n::l(line.writing.date), line.writing.id, line.writing.ref, line.writing.narration, 
           line.account.number, line.account.title, french_format(line.debit), french_format(line.credit)]
    end

    # est un proxy de ActionController::Base.helpers.number_with_precicision
    # TODO faire un module qui gère ce sujet car utile également pour table.rb
    def french_format(r)
      return '' if r.nil?
      return ActionController::Base.helpers.number_with_precision(r, :precision=>2)  if r.is_a? Numeric
      r
    end

  end

end
