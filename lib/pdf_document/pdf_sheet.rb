# coding: utf-8

require 'pdf_document/default'


module PdfDocument


  class PdfSheet < PdfDocument::Simple

    # on part de l'idée qu'une rubriks prend toujours moins d'une page à imprimer
    # mais surtout actuellement on surcharge pour éviter que source cherche à compter des lignes
    def nb_pages
      1
    end

    def render
      to_pdf.render
    end

  # Crée le fichier pdf associé
  def to_pdf(template = "lib/pdf_document/prawn_files/sheet.pdf.prawn")
    text  =  ''
    File.open(template, 'r') do |f|
      text = f.read
    end
    #       puts text
    require 'prawn'
    doc = self # doc est utilisé dans le template
    @pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => :portrait) do |pdf|
      pdf.instance_eval(text)
    end
    numerote
    @pdf_file
  end
end

end