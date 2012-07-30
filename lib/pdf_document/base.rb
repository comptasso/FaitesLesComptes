# coding: utf-8

# TODO on pourrait remplacer le tableau de string columns par des objets columns

require 'pdf_document/page'
require 'pdf_document/table'

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
  # la source est un objet capable de répondre à une méthode (par défaut lines)
  # qui sont appelées par l'objet Pdf::Page
  #
  # Ce qu'on souhaite obtenir peut être défini soit par des options soit par des méthodes
  # 
  # Les arguments obligatoires sont 
  #   period : l'exercice concerné par la demande
  #   source : la classe qui sert de source (par exemple un compte)
  # 
  # Les options disponibles sont : 
  # :title => pour définir le titre du document - l'option title est obligatoire
  # :subtitle => pour définir le sous titre
  # :from_date => date de début (par défaut la date de début de l'exercice)
  # :to_date => date de fin (par défaut la date de fin de l'exercice)
  # :stamp => le texte qui apparaît en fond de document (par exemple brouillard ou provisoire)
  # 
  # La classe a des méthodes pour définir les colonnes souhaitées de la source et différents paramétrages
  #
  # set_columns(array_of_string) permet d'indiquer les colonnes souhaitées (par ex : set_columns %w(line_date, nature_id, debit)
  #   par défaut set_columns prend l'ensemble des champs de la table Lines
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
  # set_columns_to_totalize(array_of_indices) : l'indice des colonnes pour lesquels on demande un total
  #   a priori, la première colonne ne devrait pas être totlaisable pour permette d'écrire Total, Report
  #   par exemple set_columns_to_totalize [2] pour totaliser le champ debit.
  #   Les lignes de report et de totaux seront alors de la forme [Total, valeur]
  #
  # set_columns_titles(array_of_string) permet d'indiquer les titres de colonnes
  #   par exemple set_columns_titles %w(Date Nature Débit)
  #
  # first_report_line(array) permet d'insérer dans la première page une ligne de report
  #   par exemple first_report_lines['soldes au 01/03/2012', '212.00']
  #   La valeur (ici 212) sera alors reprise pour faire les totaux de la page et le calcul des reports
  #
  # La méthode page(number) permet d'appeler une page spécifique du pdf
  # La méthode render permet de rendre le pdf construit sous forme de string en utilisant le fichier
  # lib/pdf_document/test.pdf.prawn.
  #
  # TODO faire un argument par défaut pour pouvoir choisir un autre template
  #
  class Base
    include ActiveModel::Validations
     attr_accessor :title, :subtitle, :columns_title, :total_columns_widths, :columns_alignements, :columns_formats, :first_report_line
     attr_reader :created_at, :from_date, :to_date, :nb_lines_per_page, :source, :columns_to_totalize, :stamp
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
       @stamp = options[:stamp]
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


      # permet de choisir les colonnes que l'on veut sélectionner pour le document
      # set_columns appelle set_columns_widths pour calculer la largeur des colonnes
      # sur la base de largeurs égales.
      # Si on veut fixer les largeurs, il faut alors appeler set_columns_widths
      #
      def set_columns(array_columns = nil)
       @columns = array_columns || @source.lines.first.class.column_names
       set_columns_widths
       set_columns_alignements
      
       @columns
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
       raise ArgumentError , 'Le tableau des colonnes ne peut être vide' if indices.empty?
       @columns_to_totalize = indices
       set_total_columns_widths
     end



     def select_method
       @select_method ||= :lines
     end 

     # Crée le fichier pdf associé 
     def render(template = "lib/pdf_document/default.pdf.prawn")
       
       text  =  ''
       File.open(template, 'r') do |f|
          text = f.read
       end
#       puts text
       require 'prawn'
       doc = self # doc est utilisé dans le template
       pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => :landscape) do |pdf|
            pdf.instance_eval(text)
          end
       pdf_file.render
     end

     private

      # méthode permettant de donner la largeur des colonnes pour une ligne de
     # total
     def set_total_columns_widths
       raise 'Impossible de calculer les largeurs des lignes de total car les largeurs de la table ne sont pas fixées' unless @columns_widths
       @total_columns_widths = []
       # si la colonne est à totaliser on retourne la valeur
       # sinon on la garde et on examine la colonne suivant
       l = 0 # variable pour accumuler les largeurs des colonnes qui ne sont pas à totaliser
       @columns_widths.each_with_index do |w,i|
         if @columns_to_totalize.include? i
           if l != 0
           @total_columns_widths << l
           l = 0
           end
           @total_columns_widths << w
         else
           l += w
         end
       end
       @total_columns_widths
     end

     # définit un aligment des colonnes par défaut, les colonnes qui sont
     # numériques sont alignées à droite, les autres à gauche
     def set_columns_alignements
       # on prend les colonnes sélectionnées et on construit un tableau
       # left, right selon le type de la colonne
       lch = Line.columns_hash
       @columns_alignements = @columns.map do |c|
         (lch[c].number? && lch[c].name !~ /_id$/) ? :right : :left
       end
       @columns_alignements
     end

    







  end
end
