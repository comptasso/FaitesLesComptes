# coding: utf-8

require 'prawn'

module PdfDocument
  
  # module pour contenir des méthodes communes pour l'édition des pdf, notamment
  # numerote pour la numérotation des pages;
  # entetes pour les entetes des pages avec les méthodes top_left, title,...
  # pour construire l'entete.
  module Common
    protected

    # réalise la pagination de @pdf_file
    def numerote
      @pdf_file.number_pages("page <page>/<total>",
        { :at => [@pdf_file.bounds.right - 150, 0],:width => 150,
          :align => :right, :start_count_at => 1 })
    end

  end
  
  
  
end