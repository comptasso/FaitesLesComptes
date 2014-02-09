# coding: utf-8

# require 'yaml'

# TODO probablement à rebaptiser en Compta::Folio
# TODO supprimer Compta::Sheet après 

# Sheet est destinées à éditer une liste de rubriks concrètement pour un exercice donné
# 
# Le but est de construire des sous parties de bilan ou de comtpe de résultats
# Les arguments sont period, et un folio
# 
#  TODO voir pour faire le document avec une collection de folio
#  par exemple bilan qui est actif et passif
#  ou liasse qui est l'ensemble  
# 
# TODO La méthode to_index_csv est précisément capable de faire un document composite
# mais il devrait être possible de faire une seule méthode avec *args
# 
#
# sens permet de savoir si on est un document avec une logique d'actif ou de passif
# Cette logique permet en fait de choisir si les nombres credit ou débit sont positifs
# 
# A partir de folio qui possède des rubriks et de period qui donne l'exercice
# Sheet dispose de méthodes pour produire les données qui seront utilisées
# - to_csv pour le format csv
# - to_pdf pour le format pdf 
#  

# A la différence de csv et pdf qui construisent toutes les données dans la méthode,
#  pour l'affichage dans la vue, il suffit de renvoyer la rubrique root et la vue et 
#  ses partial se chargent de construire l'ensemble.
#
module Compta

  class Sheet
    
    include Utilities::ToCsv
    include ActiveModel::Validations
    
    attr_accessor  :name, :title, :folio, :period

    def initialize(period, folio)
      @folio = folio
      @period = period
      @name = folio.name
      @title = folio.title
    end
    
    def sens
      folio[:sens].to_sym
    end
    
    # liste les rubriques et les lignes de compte qui ont permis de les construire
    # 
    # Egalement utilisé par Editions::DetaileSheet. D'où le page number qui n'est
    # pas à ce stade utilisé. 
    #
    def fetch_lines(page_number = 1)
      folio.root.fetch_lines(@period)
    end
    
    # liste les rubriques
    def fetch_rubriks
      folio.root.fetch_rubriks(@period)
    end

    # TODO voir pour refactoriser celà mais il ne faut pas oublier que dans un cas
    # to_csv on ne garde que 3 colonnes pour un sens passif, tandis que dans le cas 
    # de to_index_csv on garde les 5 colonnes mais on met à blanc deux colonnes
    # pour les documents resultat, passif et bénévolat car la collection peut aussi c
    # comprendre actif. D'où ce passage par prepare_line
 
    # utilisé pour le csv de l'option show, c'est à dire avec un seul sheet
    # show veut dire une édition avec le détail des lignes, d'où l'utilisation de fetch_lines
    def to_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << [title.capitalize] # par ex Actif
        csv << entetes  # la ligne des titres
        fetch_lines.each do |rub|
          csv << (sens==:actif ? prepare_line(rub, sens) : format_line(rub.total_passif))
        end
      end
    end


    # utilisé pour le csv de l'action index, donc a priori avec plusieurs sheet
    # ici on n'affiche donc pas le détail et l'on ne prend que les rubriques
    # d'où l'appel à fetch_rubriks
    def to_index_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << [title.capitalize] # par ex Actif
        csv << index_entetes # la ligne des titres
        fetch_rubriks.each do |rub|
          csv << prepare_line(rub, sens)
        end
      end
    end
 
    # encodage windows
    def to_index_xls(options = {col_sep:"\t"})
      to_index_csv(options).encode("windows-1252") 
    end

    # fait une édition pdf de sheet en s'appuyant sur la classe Edition::Sheet
    #
    def to_pdf(options = {})
      options[:title] =  folio.title 
      options[:subtitle] = folio.subtitle
      Editions::Sheet.new(@period, self, options)
    end
    
    # rend le fichier pdf
    def render_pdf
      to_pdf.render 
    end

   # produit une édition pdf de Sheet avec les détails de lignes
    def to_detailed_pdf(options = {})
      options[:title] =  name.to_s
      Editions::DetailedSheet.new(@period, self, options)
    end

    
   
    
    


    protected

  


    # prepare line sert à effacer les montant brut et amortissement pour ne garder
    # que le net.
    # Utile pour le passif d'un bilan et pour les comptes de résultats qui n'ont pas
    # la même logique qu'une page actif.
    # prepare_line assure également la mise en forme des lignes au format français
    # pour les exportations vers le tableur.
    def prepare_line(rub, actif_passif)
      line = rub.total_actif
      if actif_passif != :actif
        line[1] = line[2]= ''
      end
      format_line(line)
    end

    # utilise le helper numeric_with_precision pour gérer la transmission
    # des données vers les pdf et les csv.
    def format_line(line)
      line.collect do |element|
        if element.is_a? Numeric
          ActionController::Base.helpers.number_with_precision(element, :precision=>2)
        else
          element
        end
      end
    end

    # prépare les entêtes utilisés pour le fichier csv
    def entetes
      sens == :actif ? %w(Rubrique Brut Amort Net Précédent) : %w(Rubrique Montant Précédent)
    end
    
    # ici on garde 5 colonnes car on est dans une action index et la collection peut
    # comprendre des documents des deux types (3 et 5 colonnes)
    def index_entetes
      sens == :actif ? %w(Rubrique Brut Amort Net Précédent) : ['Rubrique', '', '',  'Montant', 'Précédent']
    end
    
   

  end





end