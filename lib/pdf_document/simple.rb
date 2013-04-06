# coding: utf-8



require 'prawn'
require 'pdf_document/page'

module PdfDocument

  class PdfDocumentError < StandardError; end;

  
  # la classe Simple est une classe qui imprimer juste une liste d'informations
  # avec les titres et sous titres.
  # Il n'y a pas de possibilité de faire des totaux ni donc d'afficher des reports
  # L'utilisation de Simple se fait en indiquant un exercice, une source et des options
  #
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
  class Simple

    include ActiveModel::Validations

    attr_accessor :title, :subtitle, :total_columns_widths, :columns_alignements, :columns_formats, :select_method
    attr_reader :created_at, :nb_lines_per_page, :source, :stamp
     
    validates :title, :presence=>true
    validates :select_method, :presence=>true

    def initialize(period, source, options)
      @title = options[:title]
      @created_at = Time.now
      @period = period
      @nb_lines_per_page = options[:nb_lines_per_page] || NB_PER_PAGE_LANDSCAPE
      @source = source
      @select_method = options[:select_method]
      @template = "lib/pdf_document/#{self.class.name.split('::').last.downcase}.pdf.prawn"
      @stamp = options[:stamp]
      @subtitle = options[:subtitle]
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

    # nombre de pages avec au minimum 1 page
    def nb_pages
      [(@source.instance_eval(@select_method).count/@nb_lines_per_page.to_f).ceil, 1].max
    end

    # construit l'ensemble des pages et le met dans la variable d'instance
    # @pages qui agit comme un cache
    def pages
      @pages ||= (1..nb_pages).collect {|i| PdfDocument::Page.new(i, self)}
    end

    # permet d'appeler la page number
    # retourne une instance de PdfDocument::Page
    def page(number)
      pages unless @pages # construit la table des pages si elle n'existe pas encore
      raise ArgumentError, "La page demandée n'existe pas"  unless (number > 0 &&  number <= nb_pages)
      @pages[number-1]
    end

    


    # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      source.instance_eval(@select_method).select(columns).offset(offset).limit(limit)
    end

    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # dans la classe simple, cela ne fait que renvoyer la ligne.
    #
    # Une mise en forme d'office est appliquée aux champs numériques
    #
    # A surcharger lorsqu'on veut faire un traitement de la ligne
    def prepare_line(line)
      columns_methods.collect do |m|
        val = line.instance_eval(m)
        val = ActionController::Base.helpers.number_with_precision(val, :precision=>2) if val.is_a?(Numeric)
        val
      end
    end

    # agit comme un cache.
    def columns_methods
      @columns_methods ||= set_columns_methods
    end

    # TODO : à mettre en protected
    # pour définir les méthodes à applique aux champs sélectionnés
    #
    #
    def set_columns_methods(array_methods = nil)
      @columns_methods = []

      if array_methods
        array_methods.each_with_index do |m,i|
          @columns_methods[i] = m || @columns[i]
        end
      else
        @columns_methods = columns
      end
      @columns_methods
    end
    
    # récupère les variables d'instance ou les calcule si besoin
    def columns
      @columns ||= set_columns
    end

    def columns_widths
      @columns_widths ||= set_columns_widths
    end

    def columns_titles
      @columns_titles ||= set_columns_titles
    end

    # array_wirths doit exprimer en % la largeur des colonnes
    # set_columns_widths permet d'indiquer les largeurs de colonnes souhaitées
    # Si pas d'argument, toutes les colonnes sont égales,
    #
    # Si toutes les colonnes sont définies, le total doit faire 100,
    # sinon, les colonnes restantes se partagent la place non utilisée.
    def set_columns_widths(array_widths = nil)
      if array_widths == nil
        val = 100.0/columns.size
        return  @columns_widths = columns.collect {|c| val}
      end
      # si args a moins d'argument que le nombre de colonnes, on ajoute
      diff = columns.size - array_widths.length
      if diff > 0
        place = 100 - array_widths.sum
        complement = diff.times.collect {|i| place/diff}
        array_widths += complement
      end
      # puis on retourne le nombre nécessaire

      @columns_widths = array_widths
      Rails.logger.debug "DEBUG : largeur des colonnes : "
    end


    # permet de choisir les colonnes que l'on veut sélectionner pour le document
    # set_columns appelle set_columns_widths pour calculer la largeur des colonnes
    # sur la base de largeurs égales.
    # Set_columns_widths et set_columns_alignements permettent de fixer les largeur et
    # l'alignement (:right ou :left)
    #
    def set_columns(array_columns = nil)
      @columns = array_columns || @source.instance_eval(@select_method).first.class.column_names
      set_columns_widths
      set_columns_alignements
      @columns
    end


    # permet de définir les titres qui seront donnés aux colonnes
    def set_columns_titles(array_titles = nil)
      Rails.logger.debug "Le nombre de valeurs doit être égal au nombre de colonnes, en l'occurence #{@columns.size}" if array_titles && array_titles.length != @columns.size
      @columns_titles = array_titles || @columns
    end

    # définit un aligment des colonnes, à gauche par défaut
    # TODO mettre ici, et dans toutes les méthodes similaires un
    # raise error si la taille de l'array n'est pas correcte
    def set_columns_alignements(array = nil)
      if array
        @columns_alignements = array
      else
        @columns_alignements = @columns.map{|c| :left}
      end
      @columns_alignements
    end

    
    # Crée le fichier pdf associé
    def render(template = @template)
      @columns_alignements ||= set_columns_alignements # pour être sur que les alignements soient initialisés
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

    # réalise la pagination de @pdf_file
    def numerote
      @pdf_file.number_pages("page <page>/<total>",
        { :at => [@pdf_file.bounds.right - 150, 0],:width => 150,
          :align => :right, :start_count_at => 1 })
    end



  end
end
