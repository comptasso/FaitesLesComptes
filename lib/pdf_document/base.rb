# coding: utf-8

require 'prawn'
require 'pdf_document/common'
require 'pdf_document/prawn_base'

module PdfDocument
 
  class PdfDocumentError < StandardError; end;

  
  
  
  # PdfDocument::Base est la base des classes de gestion des PdfDocument
  # 
  # L'organisation des classes est la suivante :
  # 
  # Base et ses enfants sont là pour permettre à un modèle de produire un pdf.
  # PdfDocument::Base (et ses enfants) fournissent les méthodes permettant de 
  # produire une page, une table, les sous totaux qui vont bien,... Toutes choses
  # qui viendraient inutilement encombrer le modèle qui n'a plus besoin que d'une méthode
  # to_pdf.
  # 
  # Base (et ses enfants) s'appuient alors sur une autre class (PrawnBase pour Base) pour
  # ce qui concerne production du pdf proprement dite, c'est à dire, la création du 
  # document, son remplissage et son render. #   
  # 
  # 
  # Base se crée avec comme argument une collection et des options :
  # - :title pour le titre du document
  # - :subtitle pour un sous titre
  # - :columns pour les méthodes à appliquer à chaque ligne de cette collection pour obtenir les valeurs des colonnes
  # - :orientation permet de donner l'orientation :landscape ou :portrait
  # - :nb_lines_per_page
  # - :columns_titles donne le titre des colonnes du document
  #
  # Des méthodes complémentaires permettent d'affiner l'affichage :
  # - columns_widths pour définir les largeurs
  # - columns_alignements pour définir l'alignement des valeurs (:right, :center, :left)
  # - top_left pour préciser le texte qui s'affichera en haut à gauche de chaque page
  # - stamp pour précisier un fond
  #
  # Chaque page affiche une table de données qui est appelée par la méthode table
  #
  class Base
   
    include ActiveModel::Validations
        
    attr_accessor :title, :subtitle, :columns_alignements, :columns_widths,
     :columns_methods, :columns_titles, :orientation, :organism_name, :exercice, :nb_lines_per_page
    attr_accessor :top_left, :stamp
    attr_reader :created_at,   :collection

    validates :title, :columns_methods, :presence=>true
    validates :orientation, :inclusion=>{in: [:portrait, :landscape]}

# l'instance se crée avec une collection d'objets et de multiples options
# Si on fournit un bloc, il devient possible de préciser les autres valeurs
# telles que stamp, columns_widths, columns_alignements et top_left
    def initialize(collection, options)
      @collection = collection
      options.each do |k,v|
        send("#{k}=", v)
      end
      @created_at = Time.now
      yield self if block_given?
      fill_default_values
    end
    
    

    # nombre de pages avec au minimum 1 page
    def nb_pages
      [(@collection.length/@nb_lines_per_page.to_f).ceil, 1].max
    end
    
    # construit l'ensemble des pages et le met dans la variable d'instance
    # @pages qui agit comme un cache
    def pages
      @pages ||= (1..nb_pages).collect { |i| PdfDocument::Page.new(i, self) }
    end

    # permet d'appeler la page number
    # retourne une instance de PdfDocument::Page
    def page(number = 1)
      raise PdfDocumentError, 'La page demandée est hors limite' unless number.in?(1..nb_pages)  
      pages[number-1]
    end

    # enumarator permettant de parcourir les pages
    def each_page
      pages.each do |p|
        yield p
      end
    end



    # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      raise PdfDocumentError, 'La page demandée est hors limite' if !page_number.in?(1..nb_pages)
      offset = (page_number - 1)*nb_lines_per_page
      limit = [offset+nb_lines_per_page-1, collection.size].min
      collection[offset..limit]
    end

    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # A surcharger lorsqu'on veut faire un traitement de la ligne
    # Par défaut applique number_with_precision à toutes les valeurs numériques
    def prepare_line(line)
      columns_methods.collect do |m|
        val = line.send(m)
        val = ActionController::Base.helpers.number_with_precision(val, :precision=>2) if val.is_a?(Numeric)
        val
      end
    end
    
    
    
   
    
    # les alignements des colonnes par défaut sont à gauche
    def columns_alignements
      @columns_alignements ||= columns_methods.collect {|c| :left}
    end
    
    def columns_widths
      @columns_widths ||= default_columns_widths
    end
    
    # si columns_titles n'a pas été défini par l'appelant on utilise les 
    # nom des méthodes
    def columns_titles
      @columns_titles ||= default_columns_titles
    end
    
    

    # permet de définie la largeur des colonnes. Les largeurs sont spécifiées 
    # en % de la largeur de ligne.
    # Le total des valeurs doit être égale à 100
    # le total doit
    def columns_widths=(array_widths)
      raise PdfDocument::PdfDocumentError, "Le nombre de valeurs doit être égal au nombre de colonnes, en l'occurence #{columns_methods.size}" if array_widths.length != columns_methods.size
      raise PdfDocument::PdfDocumentError, "Le total des largeurs de colonnes doit être égale à 100, valeur calculée :  #{array_widths.sum}" if array_widths.sum != 100
      @columns_widths = array_widths
    end

    # définit un aligment des colonnes, à gauche par défaut
    def columns_alignements=(alignements)
      raise PdfDocumentError, "Le nombre de valeurs doit être égal au nombre de colonnes, en l'occurence #{columns_methods.size}" if alignements.length != columns_methods.size
      @columns_alignements =  alignements
    end

    # Crée le fichier pdf associé
    def render
      pdf_file = PdfDocument::PrawnBase.new(:page_size => 'A4', :page_layout => @orientation) 
      pdf_file.fill_pdf(self)
      pdf_file.render
    end

    # Permet d'insérer un bout de pdf dans un fichier pdf
    # prend un fichier pdf en argument 
    def render_pdf_text(pdf)
      pdf.fill_pdf(self)
    end

    protected 
    
    def fill_default_values
      @orientation ||= :landscape
      @subtitle ||= ''
      @nb_lines_per_page ||= NB_PER_PAGE_LANDSCAPE
    end
    
    
    # array_widths doit exprimer en % la largeur des colonnes
    # set_columns_widths permet d'indiquer les largeurs de colonnes souhaitées
    # Si pas d'argument, toutes les colonnes sont égales,
    #
    # Si toutes les colonnes sont définies, le total doit faire 100,
    # sinon, les colonnes restantes se partagent la place non utilisée.
    def default_columns_widths
        val = 100.0/columns_methods.size
        @columns_widths ||= columns_methods.collect {|c| val}
    end
    
    def default_columns_titles
      columns_methods.collect {|m| m.to_s}
    end
    
    


  end
end
