# coding: utf-8

require 'prawn'

module PdfDocument
  
  # Cette classe est totalement identique dans sa méthode fill_pdf
  # la seule qui compte vraiment. Néanmoins on la fait exister pour être 
  # en cohérence avec la hiérarchie de PdfDocument.
  class SimplePrawn < PdfDocument::BasePrawn
          
  end
  
end