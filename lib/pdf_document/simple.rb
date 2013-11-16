# coding: utf-8



require 'prawn'
require 'pdf_document/base'
require 'pdf_document/page'

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

    
     
    # récupère les variables d'instance ou les calcule si besoin
#    def columns
#      @columns ||= set_columns
#    end

#    def columns_widths
#      @columns_widths ||= set_columns_widths
#    end

#    def columns_titles
#      @columns_titles ||= set_columns_titles
#    end

    # array_widths doit exprimer en % la largeur des colonnes
    # set_columns_widths permet d'indiquer les largeurs de colonnes souhaitées
    # Si pas d'argument, toutes les colonnes sont égales,
    #
    # Si toutes les colonnes sont définies, le total doit faire 100,
    # sinon, les colonnes restantes se partagent la place non utilisée.
#    def set_columns_widths(array_widths = nil)
#      if array_widths == nil
#        val = 100.0/columns.size
#        return  @columns_widths = columns.collect {|c| val}
#      end
#      raise ArgumentError, 'le total des largeurs de colonnes ne peut être supérieur à  100 % !' if array_widths.sum > 100
#      # si args a moins d'argument que le nombre de colonnes, on ajoute
#      diff = columns.size - array_widths.length
#      if diff > 0
#        place = 100 - array_widths.sum
#        complement = diff.times.collect {|i| place/diff}
#        array_widths += complement
#      end
#      # puis on retourne le nombre nécessaire
#
#      @columns_widths = array_widths
#      Rails.logger.debug "DEBUG : largeur des colonnes : "
#    end


    # permet de choisir les colonnes que l'on veut sélectionner pour le document
    # set_columns appelle set_columns_widths pour calculer la largeur des colonnes
    # sur la base de largeurs égales.
    # Set_columns_widths et set_columns_alignements permettent de fixer les largeur et
    # l'alignement (:right ou :left)
    #
#    def set_columns(array_columns = nil)
#      @columns = array_columns || @source.instance_eval(@select_method).first.class.column_names
#      set_columns_widths
#      
#      @columns
#    end
#    
    
   
    # définit un aligment des colonnes, à gauche par défaut
    # TODO mettre ici, et dans toutes les méthodes similaires un
    # raise error si la taille de l'array n'est pas correcte
#    def set_columns_alignements(array = nil)
#      if array
#        @columns_alignements = array
#      else
#        @columns_alignements = @columns.map{|c| :left}
#      end
#      @columns_alignements
#    end

    
    # Crée le fichier pdf associé
    def render(template = @template)
      template ||= "lib/pdf_document/simple.pdf.prawn"
      text = File.open(template, 'r') {|f| f.read  }
      pages
      doc = self # doc est utilisé dans le template
      @pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => :landscape) do |pdf|
        pdf.instance_eval(text, template)
      end
      numerote
      @pdf_file.render
    end

    # Permet d'insérer un bout de pdf dans un fichier pdf
    # prend un fichier pdf en argument et évalue le contenu du template de type pdf.prawn
    # fourni en deuxième argument.
    #
    # Le but est de fonctionner comme un partial
    #
    # Retourne le fichier pdf après avoir interprété le contenu du template
    def render_pdf_text(pdf, template = @template)
      @columns_alignements ||= set_columns_alignements # pour être sur que les alignements soient initialisés
      text = File.open(template, 'r') {|f| f.read  }
      doc = self # doc est nécessaire car utilisé dans default.pdf.prawn
      Rails.logger.debug "render_pdf_text rend #{doc.inspect}, document de #{doc.nb_pages}"
      pdf.instance_eval(text, template)
    end

    protected
    
    # FIXME caveat si il n'y aucun enregistrement
    def default_columns_methods
      @collection.first.class.column_names
    end
    

    # réalise la pagination de @pdf_file
    def numerote
      @pdf_file.number_pages("page <page>/<total>",
        { :at => [@pdf_file.bounds.right - 150, 0],:width => 150,
          :align => :right, :start_count_at => 1 })
    end
    
  



  end
end
