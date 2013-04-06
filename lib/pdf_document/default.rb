# coding: utf-8

# TODO on pourrait remplacer le tableau de string columns par des objets columns

require 'pdf_document/page'
require 'pdf_document/table'
require 'pdf_document/simple'

module PdfDocument
  # La classe PdfDocument::Default est destinée à servir de base pour les
  # différents besoins de fichiers pdf.
  # 
  # Les besoins génériques assurés par cette classe sont d'avoir la capacité
  # de remplir de façon répétitive des pages pdf avec notamment
  # un numéro de page sur un nombre total de page
  # un titre de page et un sous titre 
  # le moment de l'édition 
  # le nom de l'organisme 
  # l'exercice concerné 
  # une fourchette de date 
  # un nombre de ligne par page
  # une source pour les lignes
  #
  # La classe est initialisée avec un exercice, une source et des options
  # la source est un objet capable de répondre à une méthode (par défaut compta_lines)
  # qui sont appelées par l'objet Pdf::Page
  # La récupération des lignes (des compta_lines) est faite par la méthode fetch qui
  # par défaut utilise joins(:writing).
  #
  # Ce qu'on souhaite obtenir peut être défini soit par des options soit par des méthodes
  # 
  # Les arguments obligatoires sont 
  #   period : l'exercice concerné par la demande
  #   source : la classe qui sert de source (par exemple Account pour un compte)
  # 
  # Les options disponibles sont : 
  # :title => pour définir le titre du document - l'option title est obligatoire
  # :subtitle => pour définir le sous titre
  # :from_date => date de début (par défaut la date de début de l'exercice)
  # :to_date => date de fin (par défaut la date de fin de l'exercice)
  # :stamp => le texte qui apparaît en fond de document (par exemple brouillard ou provisoire)
  # :select_method => la méthod à appliquer à la source pour trouver les lignes (compta_lines par défaut)
  # 
  # La classe a des méthodes pour définir les colonnes souhaitées de la source et différents paramétrages
  #
  # set_columns(array_of_string) permet d'indiquer les colonnes souhaitées (par ex : set_columns %w(nature_id, debit)
  #   par défaut set_columns prend l'ensemble des champs de la table Lines.
  #   Si on veut des champs qui viennent de la table writings, il faut leur donner un alias
  #   pour pouvoir les utiliser ensuite par ex : set_columns('writings.date AS w_date', 'debit').
  #   Dans set_columns_methods, décrit juste après, on utilisera alors ['w_date', nil]
  #
  # set_columns_methods(array_of_strings) pour indiquer la méthode à appliquer
  #   il doit y avoir autant de valeurs que de colonnes : nil si on veut la méthode par défaut.
  #   par exemple : set_columns_methods [nil, 'nature.name', nil]
  #
  # set_columns_widths(array_of_integer) : les valeurs du tableau expriment en % la largeur demandée,
  #   le total doit être inférieur à 100, il peut n'y avoir un nombre de valeurs inférieur au nombre de colonnes
  #   la largeur des colonnes restantes sera alors fixé en divisant la place restante par le nombre de colonnes.
  #   exemple : set_columns_widths [10, 70, 20]
  #
  #   L'ordre est important ici car set_columns_to_totalize utilise les columns_widths pour faire le
  #   calcul des largeurs de colonnes.
  #
  # set_columns_to_totalize(array_of_indices) : l'indice des colonnes pour lesquels on demande un total
  #   a priori, la première colonne ne devrait pas être totlaisable pour permette d'écrire Total, Report
  #   par exemple set_columns_to_totalize [2] pour totaliser le champ debit.
  #   Les lignes de report et de totaux seront alors de la forme [Total, valeur]
  #
  # set_columns_titles(array_of_string) permet d'indiquer les titres de colonnes
  #   par exemple set_columns_titles %w(Date Nature Débit)
  #
  # first_report_line(array) permet d'insérer dans la première page une ligne de report
  #   par exemple first_report_line['soldes au 01/03/2012', '212.00']
  #   La valeur (ici 212) sera alors reprise pour faire les totaux de la page et le calcul des reports
  #
  # La méthode page(number) permet d'appeler une page spécifique du pdf
  # La méthode render(filename) permet de rendre le pdf construit sous forme de string en utilisant le fichier
  # de template filename; par défaut lib/pdf_document/default.pdf.prawn.
  #
  # Il est possible de fonctionner avec un modèle virtuel pour autant que la classe de lines
  # puisse répondre à column_names
  #
  class Default < PdfDocument::Totalized

    attr_reader :created_at, :nb_lines_per_page, :source, :select_method
      
    attr_accessor :first_report_line
    attr_reader  :from_date, :to_date, :columns_to_totalize, :stamp
    
       
    # period est un exercice,
    # source est un record, par exemple Account
    # select_method est une méthode pour donner la collection, par defaut comptpa_lines
    def initialize(period, source, options)
      @period = period
      @source = source
      @select_method = options[:select_method] || 'compta_lines'
      yield self if block_given?
      @title = options[:title]
      @subtitle = options[:subtitle]
      @from_date = options[:from_date] || @period.start_date
      @to_date = options[:to_date] || @period.close_date
      @nb_lines_per_page = options[:nb_lines_per_page] || NB_PER_PAGE_LANDSCAPE
      @stamp = options[:stamp]
      @created_at = Time.now
      
    end

    
    # calcule de nombre de pages; il y a toujours au moins une page
    # même s'il n'y a pas de lignes dans le comptes
    # ne serait-ce que pour afficher les soldes en début et en fin de période
    def nb_pages
      nb_lines = @source.send(@select_method).range_date(from_date, to_date).count
      return 1 if nb_lines == 0
      (nb_lines/@nb_lines_per_page.to_f).ceil
    end

    
    # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      @source.compta_lines.joins(:writing=>:book).select(columns).range_date(from_date, to_date).offset(offset).limit(limit)
    end

    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # le rescue nil permet de ne pas générer une erreur si un champ composé n'est
    # pas présent.
    # Par exemple nature.name lorsque nature est nil
    def prepare_line(line)
      columns_methods.collect { |m| line.instance_eval(m) rescue nil }
    end 

    # définit un aligment des colonnes par défaut, les colonnes qui sont
    # numériques sont alignées à droite, les autres à gauche
    def set_columns_alignements(array = nil)
      if array
        @columns_alignements = array
      else
        # on prend les colonnes sélectionnées et on construit un tableau
        # left, right selon le type de la colonne
        lch = @select_method.classify.constantize.columns_hash
        @columns_alignements = @columns.map do |c|
          (lch[c] && lch[c].number? && lch[c].name !~ /_id$/) ? :right : :left
        end
      end
      @columns_alignements
    end

   

   

    

  end
end
