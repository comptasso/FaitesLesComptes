# coding: utf-8



require 'prawn'
require 'pdf_document/base'
require 'pdf_document/page'
require 'pdf_document/simple_prawn'

module PdfDocument

  class PdfDocumentError < StandardError; end;

  
  # la classe Simple est une classe qui imprime juste une liste d'informations
  # avec les titres et sous titres.
  # Il n'y a pas de possibilité de faire des totaux ni donc d'afficher des reports
  # L'utilisation de Simple se fait en indiquant un exercice, une source et des options
  #
  # La différence avec PdfDocument::Base est que Base travaille à partir d'une 
  # collection qui est un array, tandis que Simple travaille à partir d'une source
  # par exemple un exercice et d'une méthode par exemple :accounts pour générer cette
  # collection
  # 
  # Les méthodes fetch_lines sont donc surchargées pour prendre en compte cette différence
  # d'approche.
  #
  # Les options obligatoires sont title et select_method
  # Select_method sera alors utilisée pour récupérer les informations nécessaires
  #
  # Différentes méthodes permettent de définir les données que l'on veut utiliser
  # Notamment :
  # - set_columns qui permet de choisir les méthodes à appliquer à une ligne pour obtenir la valeur pour cette colonne.
  # - set_columns_widths qui définit la largeur des colonnes
  # - set columns_titles : définit les titres
  # - set_columns_alignements : définit les alignements
  #
  # Exemple pour une balance
  # PdfDocument::Simple.new(period, balance, {:select_method=>'accounts', :title=>'Liste des comptes'}
  #
  # Par défaut, les méthodes sont les entêtes de colonnes mais set_columns_methods permet
  # d'appliquer un traitement. Par exemple , en revenant sur la méthode set_columns :
  #
  #   Un exemple simple :set_columns %w(nature_id, debit)
  #
  #   Si on veut des champs qui viennent d'une table associée, par exemple
  #   de la table writings avec des compta_lines, il faut leur donner un alias
  #   pour pouvoir les utiliser ensuite par ex : set_columns('writings.date AS w_date', 'debit').
  #   Dans set_columns_methods, décrit juste après, on utilisera alors ['w_date', nil]
  #
  #   set_columns_methods(array_of_strings) permet d'indiquer la méthode à appliquer dans prepare_line.
  #
  #   Il doit y avoir autant de valeurs que de colonnes : nil si on veut la méthode par défaut.
  #   par exemple : set_columns_methods [nil, 'nature.name', nil]
  #
  # D'autres options sont possibles
  #  - nb_lines_per_page pour définir le nombre de lignes dans la page.
  #  - stamp pour définir un timbre de fond (brouillard ou provisoire par exemple)
  #  - subtitle pour un sous-titre
  #
  # Simple fonctionne sur un mode paysage.
  #
  class Simple < PdfDocument::Base

    include ActiveModel::Validations
    
    attr_accessor :total_columns_widths, :select_method
       
    validates :title, :presence=>true
    validates :select_method, :presence=>true

    def initialize(period, source, options)
      @period = period
      @source = source
      
      options.each do |k,v|
        send("#{k}=", v)
      end
      @created_at = Time.now
      # instance_eval car @select_method peut alors être complexe, par exemple 
      # accounts.order(:number) - ce que ne permet pas un send
      raise PdfDocument::PdfDocumentError, 'Vous devez fournir une select_method pour extraire les données de la source' unless @select_method
      @collection = @source.instance_eval(@select_method) 
      yield self if block_given?
      fill_default_values
    end
    
    def fill_default_values
      super
      @columns_methods ||= default_columns_methods
    end

    # cette méthode ne fait que rajouter un test sur l'existence de la 
    # capacité de la source à répondre à cette méthode
    def select_method=(meth)
      # raise ArgumentError, 'la source ne répond pas à la méthode sectionnée' unless @source.respond_to?(meth)
      @select_method = meth
    end
       
    # méthodes pour disposer des infos par self dans le template
    def organism_name
      @period.organism.title
    end

    def exercice
      @period.exercice
    end

    def previous_exercice
      @period.previous_exercice
    end

    
    # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      raise PdfDocumentError, 'La page demandée est hors limite' if !page_number.in?(1..nb_pages)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      collection.select(columns_methods).offset(offset).limit(limit)
    end

    # appelle les méthodes adéquate pour chacun des éléments de la ligne
    # dans la classe simple, cela ne fait que renvoyer la ligne.
    #
    # Une mise en forme d'office est appliquée aux champs numériques
    #
    # A surcharger lorsqu'on veut faire un traitement de la ligne
    def prepare_line(line)
      columns_methods.collect do |m|
        val = line.send(m)
        val = ActionController::Base.helpers.number_with_precision(val, :precision=>2) if val.is_a?(Numeric)
        val
      end
    end
    
    # Crée le fichier pdf associé
    def render
      pdf_file = PdfDocument::SimplePrawn.new(:page_size => 'A4', :page_layout => @orientation) 
      pdf_file.fill_pdf(self)
      pdf_file.render
    end

    
    
    protected
    
    # FIXME caveat si il n'y aucun enregistrement
    def default_columns_methods
      collection.first.class.column_names
    end
    

    
    
  



  end
end
