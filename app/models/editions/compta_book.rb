# coding: utf-8
require 'pdf_document/base_totalized'

module Editions

  # Classe destinée à imprimer un livre ou un extrait de livre en format pdf
  # Il s'agit ici plus d'imprimer
  #
  # Cette classe hérite de PdfDocument::Totalized
  # 
  # Elle surcharge prepare_line car la collection est une collection mixte
  # avec des writings et des compta_lines
  # 
  # 
  class ComptaBook < PdfDocument::BaseTotalized

    
    
    def title
      super
    end
    
    # Si la ligne est une writing, on affiche la date, le numéro de pièce, la réf
    # et la narration.
    # 
    # Si la ligne est une compta_line on affiche le compte, le libéllé, le débit et le crédit.
    #
    def prepare_line(line)
      line.to_pdf
    end
    
   

  end
end
