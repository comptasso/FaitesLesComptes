# coding: utf-8

require 'pdf_document/default.rb'

module Editions

  # Classe pour faire l'édition pdf des listings de comptes
  # 
  # La classe hérite de Default et surcharge la méthode prepare_line
  # ainsi que la méthode fetch_lines car on reprend pour les lignes celles 
  # qui ne sont pas dans le livre d'A Nouveau
  #
  class Account < PdfDocument::Default

    def initialize(period, source, options)
      super(period, source, options)
      @title = "Liste des écritures du compte #{source.number}"
      @subtitle= "Du #{I18n::l @from_date} au #{I18n.l @to_date}"
      @stamp  = "brouillard" unless source.all_lines_locked?(@from_date, @to_date)
      set_columns ['writings.date AS w_date', 'books.title AS b_title', 'writings.ref AS w_ref', 'writings.narration AS w_narration', 'nature_id', 'destination_id', 'debit',  'credit']
      set_columns_methods ['w_date', 'b_title', 'w_ref', 'w_narration', 'nature.name', 'destination.name', nil, nil]
      set_columns_widths [10, 8, 8, 24, 15, 15, 10, 10]
      set_columns_titles %w(Date Jnl Réf Libellé Nature Destination Débit Crédit)
      set_columns_to_totalize [6,7]
      self.first_report_line = ["Soldes au #{I18n::l @from_date}"] + source.formatted_sold(@from_date)

    end

 
    def prepare_line(line)
      [I18n::l(Date.parse(line.w_date)), line.b_title, line.w_ref, line.w_narration, (line.nature ? line.nature.name  : ''),
         (line.destination ? line.destination.name  : ''),
         ActionController::Base.helpers.number_with_precision(line.debit, precision:2),
         ActionController::Base.helpers.number_with_precision(line.credit, precision:2)]
    end

    # renvoie les lignes de la page demandées
    # Account ne prend pas en compte les lignes d'à nouveau dans la liste des écritures
    # mais le prend dans le solde d'ouverture 
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      @source.compta_lines.with_writing_and_book.select(columns).without_AN.range_date(from_date, to_date).offset(offset).limit(limit)
    end


  end
end