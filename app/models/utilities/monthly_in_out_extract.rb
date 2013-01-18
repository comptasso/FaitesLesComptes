# coding: utf-8

require 'month_year'
require 'pdf_document/book' 

module Utilities


  # un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
  # se créé en appelant new avec un book et une date quelconque du mois souhaité
  # my_hash est un hash :year=>xxxx, :month=>yy
  class MonthlyInOutExtract < Utilities::InOutExtract

    def initialize(book, my_hash)
      @titles = ['Date', 'Réf', 'Libellé', 'Destination', 'Nature', 'Débit', 'Crédit', 'Paiement', 'Support']
      @book = book
      @my = MonthYear.new(my_hash)
      @begin_date = @my.beginning_of_month
      @end_date = @begin_date.end_of_month
      @period = @book.organism.find_period(@begin_date)
    end

      
    def month
      @my.to_format('%B %Y')
    end

    protected
    # détermine les options pour la publication du pdf
    #
    # La méthode est identique à celle de InOutExtract à l'excption de
    # subtitle qui précise le mois
    def options_for_pdf
      {
        :title=>book.title,
        :subtitle=>"Mois de #{month}",
        :from_date=>@begin_date,
        :to_date=>@begin_date.end_of_month,
        :stamp=> provisoire? ? 'Provisoire' : ''
        }
    end



    
  

  end


end
