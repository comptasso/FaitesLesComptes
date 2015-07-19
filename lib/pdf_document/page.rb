# coding: utf-8

require 'pdf_document/table'

module PdfDocument
  class Page

    attr_reader :number, :table, :document
    
    def initialize(number, doc)
      @number =  number
      @document = doc
    end

    def stamp
      document.stamp
    end

    def top_left
      "#{document.organism_name}\n#{document.exercice}"
    end

    def title
      document.title
    end

    def subtitle
      document.subtitle
    end

    def top_right
      I18n::l(document.created_at, :format=>"Edition du\n%e %B %Y\nà %H:%M:%S")
    end

    def table_title
      pdf_table.title 
    end

    def table_columns_widths
      document.columns_widths
    end

    def total_columns_widths
      document.total_columns_widths
    end

    def table_lines
      pdf_table.prepared_lines.collect {|l| format_line(l)}
    end

    def table_lines_depth
      pdf_table.depths
    end

    def table_total_line
      @ttl ||= format_line table_float_total_line
    end
    
    # pour conserver en mémoire les valeurs des totaux
    def table_float_total_line
      @tftl ||= pdf_table.total_line
    end

    # forunit le report
    def table_report_line
      @trl ||= set_table_report_line
    end
    
    def set_table_report_line
      return document.first_report_line if @number == 1 # première page
      r =  document.page(@number -1).table_to_report_line
      r[0] = 'Reports'
      r
    end

    
    # additionne la ligne de report (si elle existe) et la ligne de total
    def table_to_report_line
      # cas où la ligne de report n'existe pas
      # on prend la ligne total et on change juste le titre
      unless  table_report_line
        r = table_total_line
      else
        r =[]
        table_report_line.each_with_index do |v,i|
          r << french_format(french_to_f(v) + french_to_f(table_total_line[i]))
        end
      end
      r[0] =  last_page? ? 'Total général' : 'A reporter'
      r 
    end


   

    # indique si on est sur la dernière page
      def last_page?
        @number == document.nb_pages
      end

     protected


    # construit une table en donnant comme argument la page 
    def pdf_table
      @table ||= Table.new(self)
    end

    # appelle la méthode french_format pour chaque élément de ligne
    def format_line(l)
      l.collect {|v| french_format(v)}
    end

    # est un proxy de ActionController::Base.helpers.number_with_precicision
    # TODO faire un module qui gère ce sujet car utile également pour table.rb
    def french_format(r)
      return '' if r.nil?
      return I18n::l(r) if r.is_a? Date
      return ActionController::Base.helpers.number_with_precision(r, :precision=>document.precision)  if r.is_a? Numeric
      r
    end

    # transforme un string représentant un nombre en format français, par exemple
    # '1 300,25' en un float que le programme saura additionner.
    #
    # On prévoit le cas ou number serait malgré tout Numeric en retournant la valeur
    #
    # TODO faire une sous classe de Float qui sache additionner nativement le
    # format français.
    def french_to_f(number = 0)
      number.is_a?(Numeric) ? number : number.gsub(',', '.').gsub(' ', '').to_f rescue 0
    end

   
    

  end
end
