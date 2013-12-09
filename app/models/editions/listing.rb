# coding: utf-8

require 'pdf_document/default.rb' 

module Editions

  # Classe pour faire l'édition pdf des listings de comptes
  # 
  # La classe hérite de Default et surcharge la méthode prepare_line
  # ainsi que la méthode fetch_lines car on reprend pour les lignes celles 
  # qui ne sont pas dans le livre d'A Nouveau
  # TODO changer pour Listing pour être cohérent avec les actions csv et view
  class Listing < PdfDocument::Default 

    
    # il faut appeler super pour que toutes les valeurs soient déterminées, 
    # notamment orientation, nb_lines_per_page,...
    def fill_default_values
      super
      @title ||= "Listing compte #{source.number}"
      @subtitle ||= "#{source.title} - Du #{I18n::l @from_date} au #{I18n.l @to_date}"
      @stamp  = "brouillard" unless source.all_lines_locked?(@from_date, @to_date)
      @columns_select = ['writings.id AS w_id', 'writings.date AS w_date', 'books.abbreviation AS b_abbreviation', 'writings.ref AS w_ref', 'writings.narration AS w_narration', 'nature_id', 'destination_id', 'debit',  'credit']
      @columns_methods = ['w_id', 'w_date', 'b_abbreviation', 'w_ref', 'w_narration', 'nature.name', 'destination.name', nil, nil]
      @columns_widths =  [6, 8, 6, 8, 24, 15, 15, 9, 9]
      @columns_alignements = 7.times.collect {:left} + 2.times.collect {:right}
      @columns_titles = %w(N° Date Jnl Réf Libellé Nature Destination Débit Crédit)
      self.first_report_line = ["Soldes au #{I18n::l @from_date}"] + source.formatted_sold(@from_date)
      @columns_to_totalize = [7,8]
      
    end

 
    def prepare_line(line)
      [line.w_id, 
       I18n::l(Date.parse(line.w_date)),
       line.b_abbreviation,
       line.w_ref,
       line.w_narration,
       (line.nature ? line.nature.name  : ''),
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
      source.compta_lines.with_writing_and_book.select(columns_select).without_AN.range_date(from_date, to_date).offset(offset).limit(limit)
    end
    
    


  end
end