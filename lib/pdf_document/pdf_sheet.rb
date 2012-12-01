# coding: utf-8

require 'pdf_document/default'


module PdfDocument


  class PdfSheet < PdfDocument::Simple

    # on part de l'idée qu'une rubriks prend toujours moins d'une page à imprimer
    # mais surtout actuellement on surcharge pour éviter que source cherche à compter des lignes
    def nb_pages
      1
    end

    def fetch_lines(page_number = 1)
      set_columns
      fl = []
      @source.total_general.collection.each do |c|
        fl += c.to_pdf.fetch_lines if c.class == Compta::Rubriks
      end
      fl
    end

    def set_columns
      @columns = case @source.sens
      when :actif then ['title', 'brut', 'amortissement', 'net', 'previous_net']
      when :passif then ['title', 'net', 'previous_net']
      else
        raise ArgumentError, 'Le sens d\'un document ne peut être que :actif ou :passif'
      end
    end

    

    # Crée le fichier pdf associé
    def render
      text =   read_template
      doc = self # doc est utilisé dans le template
      @pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => :portrait) do |pdf|
        pdf.instance_eval(text)
      end
      numerote
      @pdf_file.render
    end

    # surcharge de Simple::render_pdf_text pour prendre en compte
    # les deux template possibles actif.pdf.prawn et passif.pdf.prawn
    def render_pdf_text(pdf)
      text =   read_template
      doc = self # doc est nécessaire car utilisé dans default.pdf.prawn
      Rails.logger.debug "render_pdf_text rend #{doc.inspect}, document de #{doc.nb_pages}"
      pdf.instance_eval(text)
    end

    protected

    def read_template
      template = case @source.sens
      when :actif then "lib/pdf_document/prawn_files/actif.pdf.prawn"
      when :passif then "lib/pdf_document/prawn_files/passif.pdf.prawn"
      else
        raise ArgumentError, 'Le sens d\'un document ne peut être que :actif ou :passif'
      end
      File.open(template, 'r') { |f| f.read}
    end

  





  end

end