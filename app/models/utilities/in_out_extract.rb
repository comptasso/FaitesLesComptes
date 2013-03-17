# coding: utf-8

require 'month_year'
require 'pdf_document/book' 

module Utilities


  # un extrait d'un livre donné avec capacité à calculer les totaux et les soldes.
  # se crée avec deux paramètres : le livre et l'exercice.
  #
  # Un enfant de cette classe MonthlyInOutExtract permet d'avoir des extraits mensuels
  # se créé en appelant new avec un book et une date quelconque du mois souhaité
  # my_hash est un hash :year=>xxxx, :month=>yy
  class InOutExtract

    # utilities::sold définit les méthodes cumulated_debit_before(date) et
    # cumulated_debit_at(date) et les contreparties correspondantes.
    include Utilities::Sold

    include Utilities::ToCsv

    attr_reader :book, :titles

    def initialize(book, period, begin_date=nil, end_date=nil)
      @book = book
      @period = period
      @begin_date = begin_date || period.start_date
      @end_date = end_date || period.close_date
    end

    def titles
     ['Date', 'Réf', 'Libellé', 'Destination', 'Nature', 'Débit', 'Crédit', 'Paiement', 'Support']
    end

    def lines
      @lines ||= @book.compta_lines.extract(@begin_date, @end_date).in_out_lines
    end

    # l'extrait est provisoire si il y a des lignes qui ne sont pas verrouillées
    def provisoire?
      lines.reject {|l| l.locked?}.any?
    end


    # TODO voir si ces méthodes sont utilisées
    def cumulated_at(date, dc)
      @book.cumulated_at(date, dc)
    end

    def total_credit
      lines.sum(:credit)
    end

    def total_debit
      lines.sum(:debit)
    end

    def debit_before
      @book.cumulated_debit_before(@begin_date)
    end

    def credit_before
      @book.cumulated_credit_before(@begin_date)
    end

    

    def to_csv(options = {:col_sep=>"\t"})
      CSV.generate(options) do |csv|
        csv << titles
        lines.each do |line|
          csv << prepare_line(line)
        end
      end
    end
    
    alias compta_lines lines

    # produit le document pdf en s'appuyant sur la classe PdfDocument::Book
    def to_pdf
      
      pdf = PdfDocument::Book.new(@period, @book, options_for_pdf)
      pdf.set_columns ['writings.date AS w_date', 'writings.ref AS w_ref',
        'writings.narration AS w_narration', 'destination_id',
        'nature_id', 'debit', 'credit', 'payment_mode', 'writing_id']
      pdf.set_columns_methods ['w_date', 'w_ref', 'w_narration',
        'destination.name', 'nature.name', 'debit', 'credit',
        'payment_mode', 'writing_id']
      pdf.set_columns_titles(titles)
      pdf.set_columns_widths([10, 8, 20,10 ,  10, 8, 8,13,13])
      pdf.set_columns_to_totalize [5,6]
       
      pdf
    end

   


    protected

     # détermine les options pour la publication du pdf
    #
    # La méthode est identique à celle de InOutExtract à l'excption de
    # subtitle qui précise le mois
    def options_for_pdf
      {
        :title=>book.title,
        :subtitle=>"Du #{I18n::l @begin_date} au #{I18n::l @end_date}",
        :from_date=>@begin_date,
        :to_date=>@end_date,
        :stamp=> provisoire? ? 'Provisoire' : ''
        }
    end

    
    #  Utilisé pour l'export vers le csv et le xls
    # 
    #   prend une ligne comme argument et renvoie un array avec les différentes valeurs
    # préparées : date est gérée par I18n::l, les montants monétaires sont reformatés poru
    # avoir 2 décimales et une virgule,...
    def prepare_line(line)
      [I18n::l(line.date),
        line.ref, line.narration.truncate(25),
        line.destination ? line.destination.name.truncate(22) : '-',
        line.nature ? line.nature.name.truncate(22) : '-' ,
        french_format(line.debit),
        french_format(line.credit),
        "#{line.payment_mode}",
        line.support.truncate(10)
      ]
    end

    # remplace les points décimaux par des virgules pour s'adapter au paramétrage
    # des tableurs français
    # TODO supprimer et remplacer par french_format
    def reformat(number)
      ActionController::Base.helpers.number_with_precision(number, :precision=>2)
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
