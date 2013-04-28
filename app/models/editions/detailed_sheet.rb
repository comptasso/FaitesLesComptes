# coding: utf-8

require 'editions/sheet'


module Editions


  # DetailedSheet permet la production de fichier pdf avec le détail des
  # comptes permettant de comprendre la construction d'un Sheet,
  # que ce soit compte de résultats, actif, passif ou bénévolat
  class DetailedSheet < Editions::Sheet

    

    def fetch_lines(page_number = 1)
      set_columns
      @source.total_general.fetch_lines
    end

    protected

    def read_template
      template = case @source.sens
        when :actif then "#{Rails.root}/app/models/editions/prawn/detailed_actif.pdf.prawn"
        when :passif then "#{Rails.root}/app/models/editions/prawn/detailed_passif.pdf.prawn"
      end
      File.open(template, 'r') { |f| f.read}
    end

  end

end