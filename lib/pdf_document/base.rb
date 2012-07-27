# coding: utf-8

module PdfDocument
  # La classe PdfDocument::Base est destinée à servir de base pour les
  # différents besoins de fichier pdf.
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
  # la source est un objet capable de répondre aux méthodes lines (et donc count) 
  # qui sont appelées par l'objet Pdf::Page
  #
  # La classe a des méthodes pour définir les colonnes souhaitées de la source
  # set_colu
  # 
  #
  class Base
    include ActiveModel::Validations
     attr_accessor :title, :subtitle, :columns_title
     attr_reader :created_at, :from_date, :to_date, :nb_lines_per_page, :source, :columns_to_totalize
     attr_writer  :select_method

    validates :title, :presence=>true

     def initialize(period, source, options)
       @title = options[:title]
       @subtitle = options[:subtitle]
       @created_at = I18n.l Time.now
       @period = period
       @from_date = options[:from_date] || @period.start_date
       @to_date = options[:to_date] || @period.close_date
       @nb_lines_per_page = options[:nb_lines_per_page] || 22
       @source = source
     end

     

     def organism_name
       @period.organism.title
     end

     def exercice
       @period.exercice
     end

     def nb_pages
       (@source.lines.count/@nb_lines_per_page.to_f).ceil
     end

     def page(number)
       raise ArgumentError unless (1..nb_pages).include? number
       Page.new(number, self)
     end

     # table_columns renvoie un hash permettant à la table de connaître
     # les colonnes à afficher, la largeur des colonnes, et un
     # booleen indiquant si on doit la totaliser.
     # le Boolean est par défaut true si la colonne est un nombre
     def table_columns

     end

     def columns_widths
       @columns_widths ||= set_columns_widths
     end

     def columns
       @columns ||= set_columns
     end

     def columns_methods
       @columns_methods ||= set_columns_methods
     end

     def columns_titles
       @columns_titles ||= set_columns_titles
     end

     # columns_size doit exprimer en % la largeur des colonnes
     # set_columns_size permet d'indiquer les largeurs de colonnes souhaitées
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
        # puis on retourne les 6 premiers
        @columns_widths = array_widths[0..5]
     end

     def set_columns(array_columns = nil)
       @columns = array_columns || @source.lines.first.class.column_names
     end

     def set_columns_methods(array_methods = nil)
       @columns_methods = []

       if array_methods
         array_methods.each_with_index do |m,i|
           @columns_methods[i] = m || @columns[i]
         end
        
# TODO faire une erreur en cas de différence de taille
       else 
         @columns_methods = columns
       end
       @columns_methods
     end

     
     def set_columns_titles(array_titles = nil)
       @columns_titles = array_titles || @columns
     end


     # les colonnes à totaliser sont indiquées par un indice
     # par exemple si on demande Date Réf Debit Credit
     # on sélectionne [2,3] pour indices
     def set_columns_to_totalize(indices)
       @columns_to_totalize = indices
     end

     def select_method
       @select_method ||= :lines
     end







  end
end
