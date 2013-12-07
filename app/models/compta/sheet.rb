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
    
    attr_accessor  :name, :folio, :period

    def initialize(period, folio)
      @folio = folio
      @period = period
      @name = folio.name
    end
    
    def sens
      folio[:sens].to_sym
    end
    
    # liste les rubriques pour les afficher au format html
    def to_detail_html
      folio.root.fetch_lines(@period)
    end
    
    def to_index_html
      folio.root.fetch_rubriks(@period)
    end

    
 
    # utilisé pour le csv de l'option show, c'est à dire avec un seul sheet
    # show veut dire une édition avec le détail des lignes, d'où l'utilisation de fetch_lines
    def to_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << [name.capitalize] # par ex Actif
        csv << entetes  # la ligne des titres
        folio.root.fetch_lines(@period).each do |rubs|
          csv << (sens==:actif ? prepare_line(rubs.total_actif) : format_line(rubs.total_passif))
        end
      end
    end


    # utilisé pour le csv de l'action index, donc a priori avec plusieurs sheet
    # ici on n'affiche donc pas le détail et l'on ne prend que les rubriques
    # d'où l'appel à fetch_rubriks_with_rubrik
    def to_index_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << [name.capitalize] # par ex Actif
        # TODO à revoir soit pour utiliser entetes
        # visiblement avec l'appel à total_actif, j'ai supposé qu'on était toujours dans un 
        # sens actif
        csv << (sens == :actif ? %w(Rubrique Brut Amort Net Précédent) : ['Rubrique', '', '',  'Montant', 'Précédent']) # la ligne des titres
        folio.root.fetch_rubriks(@period).each do |rubs|
          csv << prepare_line(rubs.total_actif)
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
      options[:title] =  name.to_s 
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

    
    # appelé par DetailedSheet pour avoir les lignes de la page sollicitée
    # En l'occurence pour les sheets qui sont a priori en une page, le paramètre page_number
    # n'est pas utilisé. Même si dans le cas d'un DetailedSheet cela fera souvent 2 pages
    # voire plus. 
    # 
    # Le pdf se débrouille cependant tout seul pour couper le tableau et faire la numérotation
    # car il n'y a pas de sous totaux affichés en bas des pages. 
    # 
    # 
    def detailed_lines(page_number = 1)
      folio.root.fetch_lines(@period)
    end

    
    
    


    protected

  


    # prepare line sert à effacer les montant brut et amortissement pour ne garder
    # que le net.
    # Utile pour le passif d'un bilan et pour les comptes de résultats qui n'ont pas
    # la même logique qu'une page actif.
    # prepare_line assure également la mise en forme des lignes au format français
    # pour les exportations vers le tableur.
    def prepare_line(line)
      if sens != :actif
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
    
   

  end





end