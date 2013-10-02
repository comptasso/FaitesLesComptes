# coding: utf-8

require 'pdf_document/default'


module Editions

  class EditionsError < StandardError; end;

  # Sheet permet de créer une page pdf à partir d'un objet Sheet.
  # Voir la classe Compta::Sheet pour plus d'information
  #
  # Sheet hérite de PdfDocument::Simple mais ajoute ou surcharge quelques méthodes
  #
  #  Sheet est en effet destiné à imprimer une information sur une seule page, la
  #  méthode nb_pages est donc surchargée pour renvoyer 1
  #
  #   Les documents sont des documents de type liasse fiscale (Bilan, Compte de Résultats)
  #   d'où le nom de Sheet.
  #
  #   Le nombre et le contenu des colonnes sont donc déterminés selon que
  #   l'on veuille imprimer un :actif ou un :passif (donné par le sympole :sens
  #   de la source. :passif est utilisé pour le compte de résultats et le bilan passif.
  #   set_columns répond à cet objectif
  #
  #   TODO faire un équivalent :passif et :resultat pour ne pas avoir à se rappeler ce détail
  #
  #   Et les titres des colones dépendent de ce qu'on imprime : un compte de résultat
  #   traite de l'exercice, tandis qu'un bilan traite de date de clôture de l'exercice.
  #   set_title_columns répond à cet objectif
  #
  class Sheet < PdfDocument::Simple

    def initialize(period, source, options)
      super # pour initialiser les données
      raise EditionsError, 'source doit répondre à la méthode :sens' unless @source.respond_to? :sens
      raise EditionsError, 'le sens de la source ne peut être qu\'actif ou passif' unless @source.sens.in? [:actif, :passif]
      set_columns # inutile d'attendre
    end

    # on part de l'idée qu'une rubriks prend toujours moins d'une page à imprimer
    # mais surtout actuellement on surcharge pour éviter que source cherche à compter des lignes
    def nb_pages
      1
    end

    def stamp
      @period.closed? ? '' : 'Provisoire' 
    end

    def fetch_lines(page_number = 1)
      fl = []
      @source.folio.root.children.each do |c|
        fl += c.to_pdf.fetch_lines unless c.leaf?
      end
      fl.compact
    end
    
    def add_children_lines(children)
      
    end

    def set_columns
      @columns = case @source.sens
      when :actif then ['title', 'brut', 'amortissement', 'net', 'previous_net']
      when :passif then ['title', 'net', 'previous_net']
      end
    end

    # si on est dans un document de type résultat, alors, on doit avoir
    # comme entête de colonne la période, par exemple Exercice 2011
    #
    # Sinon, dans un document de type bilan, les entêtes de colonnes doivent alors
    # être des dates
    def columns_titles
      if @source.name == :actif || @source.name == :passif
        ['', I18n::l(@period.close_date), I18n::l(@period.start_date - 1)]
      else # on est dans une logique de résultat sur une période
        ['', exercice, previous_exercice]
      end
    end

    # Crée le fichier pdf associé
    def render
      text =   read_template
      doc = self # doc est utilisé dans le template
      @pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => :portrait) do |pdf|
        pdf.instance_eval(text, template)
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
      pdf.instance_eval(text, template)
    end

    protected


    def template
      case @source.sens
      when :actif then "#{Rails.root}/app/models/editions/prawn/actif.pdf.prawn"
      when :passif then "#{Rails.root}/app/models/editions/prawn/passif.pdf.prawn"
      end
    end

    def read_template
      File.open(template, 'r') { |f| f.read}
    end

  





  end

end