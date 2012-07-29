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
      "#{@doc.created_at}\nPage #{@number}/#{@doc.nb_pages}"
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
      pdf_table.prepared_lines
    end

    def table_total_line
      pdf_table.total_line
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
        # TODO utiliser each_index
        table_report_line.each_with_index do |v,i|
          r << '%0.2f' % (v.to_f + table_total_line[i].to_f)
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

#    def _total(i)
#      s = table_total_line[i]
#      s =  if table_report_line
#      s
#    end

    

  end
end
