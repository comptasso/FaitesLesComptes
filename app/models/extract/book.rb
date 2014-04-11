# coding: utf-8

require 'month_year'

module Extract


  # un extrait d'un livre donné avec capacité à calculer les totaux et les soldes.
  # se crée avec deux paramètres : le livre et l'exercice.
  #
  # Ici on est dans une logique de livre de recettes et de dépenses et on n'affiche
  # que des compta_lines. 
  #
  # Une classe descendante Compta::Book est utilisée pour afficher les extraits dans
  # une logique comptable.
  # 
  # TODO refactorisation à faire : les méthodes lines avec alias compta_lines
  # pourraient devenir tout simplement compta_lines
  # 
  # Les méthodes lines surchargées des classes filles sont probablement inutiles, 
  # ce qui permettrait de supprimer les méthodes extract_lines des classes. 
  # Ou alors on garde extract_lines (mais en évitant la duplication) et on 
  # simplifie ici.
  # 
  # Voir également si on garde bank_account et monthly_bank_account car en 
  # fait il n'y a pas d'édition de ce type.
  # 
  # TODO on pourrait renommer compta_book en ledger.
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
    # utilisé par to_csv et to_xls
    def titles
     %w(Date Pce Réf Libellé Compte Intitulé Débit Crédit)
    end

    def title
      book.title
    end

    def subtitle
      "Du #{I18n::l from_date} au #{I18n::l to_date}"
    end

    # renvoie les compta_lines avec les writings et account
    # utilisé par la classe fille in_out pour les éditions de 
    # TODO voir à ne pas ssurcharger cette méthode dans les classes filles
    # et éventuellement à supprimer les méthodes extract_lines dans les modèles
    # car elles sont similaires.
    def lines
      @lines ||= @book.compta_lines.includes(:writing, :account).
        where('date >= ? AND date <= ?', from_date, to_date).order('writings.date')
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
    

    protected
    
    

    # est un proxy de ActionController::Base.helpers.number_with_precicision
    # TODO faire un module qui gère ce sujet car utile également pour table.rb
    def french_format(r)
      return '' if r.nil?
      return ActionController::Base.helpers.number_with_precision(r, :precision=>2)  if r.is_a? Numeric
      r
    end

  end

end
