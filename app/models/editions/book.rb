# coding: utf-8
require 'pdf_document/default'

module Editions

  # Classe destinée à imprimer un livre ou un extrait de livre en format pdf
  #
  # Cette classe hérite de PdfDocument::Default et surcharge fetch_lines
  class Book < PdfDocument::Totalized


    def initialize(period, book_extract)
      super(period, book_extract, {})
      @title = book_extract.book.title

      if book_extract.is_a? Utilities::MonthlyInOutExtract
        @subtitle = "Mois : #{book_extract.month}"
      else
        @subtitle = "Du #{I18n::l book_extract.begin_date} au #{I18n::l book_extract.end_date}"
      end

      
      @from_date = book_extract.begin_date
      @to_date = book_extract.end_date
      @stamp = book_extract.provisoire? ? 'Provisoire' : ''
      @select_method = 'lines'
      set_columns ['writings.date AS w_date', 'writings.ref AS w_ref',
        'writings.narration AS w_narration', 'destination_id',
        'nature_id', 'debit', 'credit', 'payment_mode', 'writing_id']
      set_columns_methods ['w_date', 'w_ref', 'w_narration',
        'destination.name', 'nature.name', 'debit', 'credit',
        'w_mode', 'writing_id']
      set_columns_titles(book_extract.titles)
      set_columns_widths([8, 6, 20 ,10 ,  10, 10, 10,13,13])
      set_columns_to_totalize [5,6]
      set_columns_alignements [:left, :left, :left, :left, :left, :right, :right, :left, :left]
    end

    # renvoie les lignes de la page demandées
#    def fetch_lines(page_number)
#      limit = nb_lines_per_page
#      offset = (page_number - 1)*nb_lines_per_page
#      source.lines.offset(offset).limit(limit)
#    end

    
    # la méthode support n'est pas directement accessible par les tables
    # donc on utilise l'id récupéré pour appelé la fonction support.
    # Une autre option possible serait d'enregistrer cette info dans la table
    # pour en faciliter la restitution. 
    # 
    # Ne pas confondre ce prepare_line pour le pdf avec celui qui est dans 
    # InOutExtract et qui est pour l'export vers excel ou csv
    # 
    # TODO : traiter ce sujet en fonction des performances 
    def prepare_line(line)
      pl = columns_methods.collect { |m| line.instance_eval(m) rescue nil }
      pl[0] = I18n::l(Date.parse(pl[0])) rescue pl[0]
      w = Writing.find_by_id(pl.last)
      pl[-1] = w.support # récupération du support
      pl[-2] = w.payment_mode
      pl
    end

    

  end
end
