# coding: utf-8

require 'pdf_document/default'


module PdfDocument


  class PdfRubriks < PdfDocument::Simple

    

    # on part de l'idée qu'une rubriks prend toujours moins d'une page à imprimer
    # mais surtout actuellement on surcharge pour éviter que source cherche à compter des lignes
    def nb_pages
      1
    end



    def fetch_lines(page_number = 1)
      fl = []
      @source.collection.each do |c|
        fl += c.to_pdf.fetch_lines if c.class == Compta::Rubriks
        fl << c if c.class == Compta::Rubrik
      end
      fl << @source
      fl
    end

    # Crée le fichier pdf associé
    def render(template = "lib/pdf_document/prawn_files/rubriks.pdf.prawn")
      text  =  ''
      File.open(template, 'r') do |f|
        text = f.read
      end
      #       puts text
      require 'prawn'
      doc = self # doc est utilisé dans le template
      @pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => :portrait) do |pdf|
        pdf.instance_eval(text, template)
      end
      numerote
      @pdf_file.render
    end
  end

end