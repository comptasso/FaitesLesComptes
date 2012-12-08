# coding: utf-8

require 'pdf_document/table'

module PdfDocument
  class Page

    attr_reader :number, :table
    
    def initialize(number, doc)
      @number =  number
      @doc = doc
    end

    def stamp
      @doc.stamp
    end

    def top_left
      "#{@doc.organism_name}\n#{@doc.exercice}"
    end

    def title
      @doc.title
    end

    def subtitle
      @doc.subtitle
    end

    def top_right
      I18n::l(@doc.created_at, :format=>"%e %B %Y\n%H:%M:%S")
    end

    def table_title
      pdf_table.title 
    end

    def table_columns_widths
      @doc.columns_widths
    end

    def total_columns_widths
      @doc.total_columns_widths
    end

    def table_lines
      pdf_table.prepared_lines.collect {|l| format_line(l)}
    end

    def table_lines_depth
      pdf_table.depths
    end

    def table_total_line
      format_line pdf_table.total_line
    end

    # forunit le report
    def table_report_line
      return @doc.first_report_line if @number == 1 # première page
      r =  @doc.page(@number -1).table_to_report_line
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
          if (v.to_f.is_a?(Float) && table_total_line[i].to_f.is_a?(Float))
            r << french_format(v.to_f + table_total_line[i].to_f)
          else
            r << ''
          end
        end
      end
      r[0] =  @number == @doc.nb_pages ? 'Total général' : 'A reporter'
      r 
    end


    protected
    # construit une table en donnant comme argument la page et le document
    # 
    def pdf_table
      @table ||= Table.new(self, @doc)
    end

    # appelle la méthode french_format pour chaque élément de ligne
    def format_line(l)
      l.collect {|v| french_format(v)}
    end

    def french_format(r)
      return '' if r.nil?
      return ActionController::Base.helpers.number_with_precision(r, :precision=>2)  if r.is_a? Numeric
      r
    end

   
    

  end
end
