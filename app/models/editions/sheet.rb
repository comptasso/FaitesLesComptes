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
  #   Ici source n'a plus la logique de source de la collection; c'est simplement
  #   un objet Sheet qui connaît son folio et qui sait ainsi récupérer les lignes. 
  #
  #   Le nombre et le contenu des colonnes sont donc déterminés selon que
  #   l'on veuille imprimer un :actif ou un :passif (donné par le sympole :sens
  #   de la source. :passif est utilisé pour le compte de résultats et le bilan passif.
  #   default_columns_methodes définit ainsi les colonnes souhaitées en fonction 
  #   du sens souhaité
  #
  #   TODO faire un équivalent :passif et :resultat pour ne pas avoir à se rappeler ce détail
  #
  #   Et les titres des colones dépendent de ce qu'on imprime : un compte de résultat
  #   traite de l'exercice, tandis qu'un bilan traite de date de clôture de l'exercice.
  #   default_columns_titles est donc surchargé à cette fin.
  #
  class Sheet < PdfDocument::Simple 

    def initialize(period, source, options)
      @select_method = 'sens' 
      super
      raise EditionsError, 'source doit répondre à la méthode :sens' unless @source.respond_to? :sens
      raise EditionsError, 'le sens de la source ne peut être qu\'actif ou passif' unless @source.sens.in? [:actif, :passif]
    end

    # on part de l'idée qu'un folio prend toujours moins d'une page à imprimer
    # mais surtout actuellement on surcharge pour éviter que source cherche à compter des lignes
    def nb_pages
      1
    end

    def stamp
      @period.closed? ? '' : 'Provisoire' 
    end
    
    
    def fetch_lines(page_number = 1)
      @source.folio.root.fetch_rubriks_with_rubrik
    end
    
    # appelle les méthodes adéquate pour chacun des éléments de la ligne;
    # l'argument period permet de transmettre l'exercice pour lequel on demande
    # les valeurs. Cet exercice et l'exercice précédent
    #
    # Une mise en forme d'office est appliquée aux champs numériques
    #
    # A surcharger lorsqu'on veut faire un traitement de la ligne
    def prepare_line(line)
      columns_methods.collect do |m|
        val = line.send(m, @period)
        val = ActionController::Base.helpers.number_with_precision(val, :precision=>2) if val.is_a?(Numeric)
        val
      end
    end
         

    # Crée le fichier pdf associé
    def render
      @pdf_file = Editions::PrawnSheet.new(:page_size => 'A4', :page_layout => :portrait) 
      collection == :actif ? @pdf_file.fill_actif_pdf(self) : @pdf_file.fill_passif_pdf(self)
      numerote
      @pdf_file.render
    end

    # surcharge de Simple::render_pdf_text pour prendre en compte
    # les deux template possibles actif.pdf.prawn et passif.pdf.prawn
    # est ici mal nommé car 
    def render_pdf_text(pdf)
      collection == :actif ? pdf.fill_actif_pdf(self) : pdf.fill_passif_pdf(self)
    end
    
    protected
    
    # si on est dans un document de type résultat, alors, on doit avoir
    # comme entête de colonne la période, par exemple Exercice 2011
    #
    # Sinon, dans un document de type bilan, les entêtes de colonnes doivent alors
    # être des dates
    def default_columns_titles  
      if @source.name == :actif || @source.name == :passif
        ['', I18n::l(@period.close_date), I18n::l(@period.start_date - 1)]
      else # on est dans une logique de résultat sur une période
        ['', exercice, previous_exercice]
      end
    end
    
    def default_columns_methods
      @columns_methods = case @source.sens
      when :actif then ['title', 'brut', 'amortissement', 'net', 'previous_net']
      when :passif then ['title', 'net', 'previous_net']
      end
    end

  end

end