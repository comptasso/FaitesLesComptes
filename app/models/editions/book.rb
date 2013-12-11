# coding: utf-8
require 'pdf_document/default'

module Editions

  # Classe destinée à imprimer un livre ou un extrait de livre en format pdf
  #
  # Cette classe hérite de PdfDocument::Totalized et prepare_line
  class Book < PdfDocument::Default

    def initialize(period, source)
      @select_method = 'compta_lines'
      super(period, source, {})
    end
    
    def title
      "Livre de #{source.title}"
    end
    
    def fill_default_values
      @from_date = source.from_date
      @to_date = source.to_date
      super
      @subtitle  = "Du #{I18n::l @from_date} au #{I18n.l @to_date}"
      # FIXME @stamp  = "provisoire" unless source.all_lines_locked?(@from_date, @to_date)
      @columns_select = ['writings.date AS w_date', 'writings.ref AS w_ref',
        'writings.narration AS w_narration', 'destination_id',
        'nature_id', 'debit', 'credit', 'payment_mode', 'writing_id']
      @columns_methods = ['writing_id', 'w_date', 'w_ref', 'w_narration',
        'destination.name', 'nature.name', 'debit', 'credit',
        'writing_id', 'writing_id' ]
      @columns_titles = %w(Pce Date Réf Libellé Destination Nature Dépenses Recettes Payt Support)
      
      @columns_widths = [5, 8, 6, 20 ,10 , 10, 10, 10, 7, 14]
      @columns_to_totalize = [6, 7]
      @columns_alignements = [:left, :left, :left, :left, :left, :left, :right, :right, :left, :left]
    end

     
    # Ne pas confondre ce prepare_line pour le pdf avec celui qui est dans 
    # InOutExtract et qui est pour l'export vers excel ou csv
    # 
    # TODO voir en fonction des performances s'il ne faudrait pas faire une requête qui
    # récupère les données plutôt que de rechercher encore l'écriture.
    # 
    def prepare_line(line)
      pl = super
      pl[0] = pl[0].to_s # pour éviter que format_line ne transforme ce chiffre
      # comme si c'était un montant en euros
      pl[1] = I18n::l(Date.parse(pl[1])) rescue pl[1]
      w = Writing.find_by_id(pl.last)
      pl[-1] = w.support # récupération du support
      pl[-2] = w.payment_mode
      pl
    end

    

  end
end
