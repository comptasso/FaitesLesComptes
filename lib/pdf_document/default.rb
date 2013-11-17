# coding: utf-8

# TODO on pourrait remplacer le tableau de string columns par des objets columns

require 'pdf_document/page'
require 'pdf_document/table'
require 'pdf_document/totalized'

module PdfDocument
  # Voir PdfDocument::Base pour les détails de fonctionnement de cette hiérarchie 
  # de classe
  # 
  # Cette classe est utilisée pour des source qui répondent à #compta_lines
  #  
  # first_report_line(array) permet d'insérer dans la première page une ligne de report
  #   par exemple first_report_line['soldes au 01/03/2012', '212.00']
  #   La valeur (ici 212) sera alors reprise pour faire les totaux de la page et le calcul des reports
  #
  # La méthode page(number) permet d'appeler une page spécifique du pdf
  # La méthode render(filename) permet de rendre le pdf construit sous forme de string en utilisant le fichier
  # de template filename; par défaut lib/pdf_document/default.pdf.prawn.
  # 
  # Une nouvelle variable @columns_select est mise en place et sert à faire 
  # la reqûete sur la base de données
  #
  #
  class Default < PdfDocument::Totalized
    
    
    attr_accessor  :from_date, :to_date, :columns_select
    
    def initialize(period, source, options)
      @select_method = 'compta_lines'
      super
    end
       
    
    # les valeurs par défaut pour un tel pdf sont 
    # - compta_lines pour select_method
    # - @period.start_date et @period.close_date
    #
    def fill_default_values
      @template = "lib/pdf_document/default.pdf.prawn"
      @from_date ||= @period.start_date
      @to_date ||= @period.close_date
      super
    end

    
    # calcule de nombre de pages; il y a toujours au moins une page
    # même s'il n'y a pas de lignes dans le comptes
    # ne serait-ce que pour afficher les soldes en début et en fin de période
    def nb_pages
      nb_lines = @source.send(@select_method).range_date(from_date, to_date).count
      return 1 if nb_lines == 0
      (nb_lines/nb_lines_per_page.to_f).ceil
    end

    
    # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      @source.compta_lines.joins(:writing=>:book).select(columns_select).range_date(from_date, to_date).offset(offset).limit(limit)
    end

    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # le rescue nil permet de ne pas générer une erreur si un champ composé n'est
    # pas présent.
    # Par exemple nature.name lorsque nature est nil
    def prepare_line(line)
      columns_methods.collect { |m| line.instance_eval(m) rescue nil }
    end 

    
    protected
    # TODO voir pour remonter cette méthode dans la hiérarchie
    # 
    # définit un alignement des colonnes par défaut, les colonnes qui sont
    # numériques sont alignées à droite, les autres à gauche
    # 
    # IMPORTANT : cette méthode suppose que select_method corresponde à un modèle 
    #
    def default_columns_alignements
        # on prend les colonnes sélectionnées et on construit un tableau
        # left, right selon le type de la colonne
        lch = @select_method.classify.constantize.columns_hash
        @columns_alignements = @columns.map do |c|
          (lch[c] && lch[c].number? && lch[c].name !~ /_id$/) ? :right : :left
        end
      @columns_alignements
    end

   

   

    

  end
end
