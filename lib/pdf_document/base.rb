# coding: utf-8

module PdfDocument

  class PdfDocumentError < StandardError; end;


  # PdfDocument::Base est la base des classes de gestion des PdfDocument
  # Base se crée avec comme argument une collection et des options :
  # - :title pour le titre du document
  # - :subtitle pour un sous titre
  # - :methods pour les méthodes à appliquer à cette collection pour obtenir les valeurs des colonnes
  # - :orientation permet de donner l'orientation :landscape ou :portrait
  # - :nb_lines_per_page
  # - :columns_titles donne le titre des colonnes du document
  #
  # Des méthodes complémentaires permettent d'affiner l'affichage :
  # - set_columns_widths pour définir les largeurs
  # - set_columns_alignements pour définir l'alignement des valeurs (:right, :center, :left)
  # - top_left pour préciser le texte qui s'affichera en haut à gauche de chaque page
  # - stamp pour précisier un fond
  #

  class Base

    include ActiveModel::Validations

    attr_accessor :title, :subtitle, :columns_alignements, :columns_widths, :top_left, :stamp
    attr_reader :created_at, :nb_lines_per_page, :columns_titles

    validates :title, :columns, :presence=>true


    def initialize(collection, options)
      @collection = collection
      @orientation = options[:orientation] || :landscape
      @title = options[:title]
      @subtitle = options[:subtitle] || ''
      @columns = options[:columns]
      @created_at = I18n.l Time.now
      @nb_lines_per_page = options[:nb_lines_per_page] || NB_PER_PAGE_LANDSCAPE
      @columns_titles = options[:columns_titles]
      yield self if block_given?
    end


    

    # nombre de pages avec au minimum 1 page
    def nb_pages
      [(@collection.length/@nb_lines_per_page.to_f).ceil, 1].max
    end


    def table(page)
      raise PdfDocumentError, 'La page demandée est hors limite' if !page.in?(1..nb_pages)
      lines = fetch_lines(page)
      lines.map {|l| prepare_line(l)}
    end

   

     # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      raise PdfDocumentError, 'La page demandée est hors limite' if !page_number.in?(1..nb_pages)
      limit = @nb_lines_per_page
      offset = (page_number - 1)*@nb_lines_per_page
      limit = [offset+@nb_lines_per_page-1, @collection.size].min
      @collection[offset..limit]
    end

    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # Dans la classe Base, les lignes sont des hash, ce qui nécessite l'utilisation de
    #  :[] puis du symbole
    # A surcharger lorsqu'on veut faire un traitement de la ligne
    def prepare_line(line)
      @columns.collect do |m|
        val = line.send(m)
        val = ActionController::Base.helpers.number_with_precision(val, :delimiter=>' ', :separator=>',') if val.is_a?(Numeric)
        val
      end
    end

   
    

    def columns_widths=(array_widths)
      raise PdfDocumentError, "Le nombre de valeurs doit être égal au nombre de colonnes, en l'occurence #{@columns.size}" if array_widths.length != @columns.size
      @columns_widths = array_widths
    end

    # définit un aligment des colonnes, à gauche par défaut
    # TODO mettre ici, et dans toutes les méthodes similaires un
    # raise error si la taille de l'array n'est pas correcte
    def columns_alignements=(alignements)
      raise PdfDocumentError, "Le nombre de valeurs doit être égal au nombre de colonnes, en l'occurence #{@columns.size}" if alignements.length != @columns.size
      @columns_alignements =  alignements
    end

    # Crée le fichier pdf associé
    def render(template = "lib/pdf_document/prawn_files/base.pdf.prawn")
      text  =  ''
      File.open(template, 'r') do |f|
        text = f.read
      end
      #       puts text
      require 'prawn'
      doc = self # doc est utilisé dans le template
      @pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => @orientation) do |pdf|
        pdf.instance_eval(text)
      end
      numerote
      @pdf_file.render
    end

     # Permet d'insérer un bout de pdf dans un fichier pdf
    # prend un fichier pdf en argument et évalue le contenu du template pdf.prawn
    # fourni en deuxième argument.
    # retourne le fichier pdf après avoir interprété le contenu du template
    def render_pdf_text(pdf, template = "lib/pdf_document/base.pdf.prawn")
      text  =  ''
      File.open(template, 'r') do |f|
        text = f.read
      end
      doc = self # doc est nécessaire car utilisé dans default.pdf.prawn
      Rails.logger.debug "render_pdf_text rend #{doc.inspect}, document de #{doc.nb_pages}"
      pdf.instance_eval(text)
    end

    # réalise la pagination de @pdf_file
    def numerote
      @pdf_file.number_pages("page <page>/<total>",
        { :at => [@pdf_file.bounds.right - 150, 0],:width => 150,
          :align => :right, :start_count_at => 1 })
    end


  end
end
