# coding: utf-8

module PdfDocument
  # la classe Simple est une classe qui imprimer juste une liste d'informations
  # avec les titres et sous titres.
  # Il n'y a pas de possibilité de faire des totaux ni donc d'afficher des reports
  class Simple
    include ActiveModel::Validations
     attr_accessor :title, :subtitle, :total_columns_widths, :columns_alignements, :columns_formats
     attr_reader :created_at, :nb_lines_per_page, :source
     

    validates :title, :presence=>true
    validates :select_method, :presence=>true

     def initialize(period, source, options)
       @title = options[:title]
       @created_at = I18n.l Time.now
       @period = period
       @nb_lines_per_page = options[:nb_lines_per_page] || 22
       @source = source
       @select_method = options[:select_method]
     end


     # méthodes pour disposer des infos par self dans le template
     def organism_name
       @period.organism.title
     end

     def exercice
       @period.exercice
     end

     # nombre de pages avec au minimum 1 page
     def nb_pages
       [(@source.instance_eval(@select_method).count/@nb_lines_per_page.to_f).ceil, 1].max
     end

     # permet d'appeler la page number
     # retourne une instance de PdfDocument::Page
     def page(number)
       raise ArgumentError unless (1..nb_pages).include? number
       Page.new(number, self)
     end

     # renvoie les lignes de la page demandées
     def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      source.instance_eval(@select_method).select(columns).offset(offset).limit(limit)
     end

     # appelle les méthodes adéquate pour chacun des éléments de la lignes
     # dans la classe simple, cela ne fait que renvoyer la ligne.
     # A surcharger lorsqu'on veut faire un traitement de la ligne
     def prepare_line(line)
       columns.collect { |m| line.instance_eval(m) }
     end

     # récupère les variables d'instance ou les calcule si besoi
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
        @columns_widths = array_widths[0..columns.size]
     end


      # permet de choisir les colonnes que l'on veut sélectionner pour le document
      # set_columns appelle set_columns_widths pour calculer la largeur des colonnes
      # sur la base de largeurs égales.
      # Si on veut fixer les largeurs, il faut alors appeler set_columns_widths
      #
      def set_columns(array_columns = nil)
       @columns = array_columns || @source.instance_eval(@select_method).first.class.column_names
       set_columns_widths
       @columns
     end

    def set_columns_alignements(array_alignements)
      @columns_alignements = array_alignements
    end

 
     def set_columns_titles(array_titles = nil)
       @columns_titles = array_titles || @columns
     end

    
     # Crée le fichier pdf associé
     def render(template = "lib/pdf_document/simple.pdf.prawn")
       text  =  ''
       File.open(template, 'r') do |f|
          text = f.read
       end
#       puts text
       require 'prawn'
       doc = self # doc est utilisé dans le template
       @pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => :landscape) do |pdf|
            pdf.instance_eval(text)
          end
       numerote
       @pdf_file.render
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
