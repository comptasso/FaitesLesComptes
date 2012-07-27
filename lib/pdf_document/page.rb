# coding: utf-8

require 'pdf_document/table'

module PdfDocument
  class Page

    attr_reader :number, :table

    def initialize(number, doc)
      @number =  number
      @doc = doc
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

    def table_lines
      pdf_table.prepared_lines
    end

    def table_total_line
      pdf_table.total_line
    end

    # forunit le report
    def table_report_line
      return nil if @number == 1 # première page
      r =  @doc.page(@number -1).table_to_report_line
      r[0] = 'Reports'
      r
    end

    def table_to_report_line
      r = ['A reporter']
      @doc.columns[1..@doc.columns.size-1].each_with_index do |c,i|
        if @doc.columns_to_totalize.include?(i+1)
         r << _total(i+1)
        else 
          r < ''
        end
      end
      r[0] = 'Total général' if @number == @doc.nb_pages
      r
    end


protected
    # construit une table en donnant comme argument la page et le document
    # 
    def pdf_table
       @table ||= Table.new(self, @doc)
    end

    def _total(i)
      s = table_total_line[i]
      s += table_report_line[i] if table_report_line
      s 
    end

    

  end
end
