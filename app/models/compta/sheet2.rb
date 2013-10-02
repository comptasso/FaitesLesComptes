# coding: utf-8

# require 'yaml'

# TODO probablement à rebaptiser en Compta::Folio
# TODO supprimer Compta::Sheet après 

# Sheet2 est destinées à éditer une liste de rubriks concrètement pour un exercice donné
# 
# Le but est de construire des sous parties de bilan ou de comtpe de résultats
# Les arguments sont period, et un folio
# 
#  TODO voir pour faire le document avec une collection de folio
#  par exemple bilan qui est actif et passif
#  ou liasse qui est l'ensemble  
# 
# TODO La méthode to_index_csv est précisément capable de faire un document composite
# mais il devrait être capable de faire une seule méthode avec *args
# 
#
# sens permet de savoir si on est un document avec une logique d'actif ou de passif
# Cette logique permet en fait de choisir si les nombres credit ou débit sont positifs
# 
#  
#
module Compta

  class Sheet2
    
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

    
# 
    # utilisé pour le csv de l'option show
    def to_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << [name.capitalize] # par ex Actif
        csv << entetes  # la ligne des titres
        folio.root.fetch_lines(@period).each do |rubs|
          csv << (sens==:actif ? prepare_line(rubs.total_actif) : format_line(rubs.total_passif))
        end
      end
    end


    # utilisé pour le csv de l'action index
    def to_index_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << [name.capitalize] # par ex Actif
        # TODO à revoir soit pour utiliser entetes
        # visiblement avec l'appel à total_actif, j'ai supposé qu'on était toujours dans un 
        # sens actif
        csv << (sens == :actif ? %w(Rubrique Brut Amort Net Précédent) : ['Rubrique', '', '',  'Montant', 'Précédent']) # la ligne des titres
        folio.root.fetch_rubriks_with_rubrik.each do |rubs|
          csv << prepare_line(rubs.total_actif)
        end
      end
    end
 
    def to_index_xls(options = {col_sep:"\t"})
      to_index_csv(options).encode("windows-1252") 
    end



    # fait une édition pdf de sheet ce qui reprend des titres puis insère les éléments
    #
    def to_pdf(options = {})
      options[:title] =  name.to_s 
      Editions::Sheet.new(@period, self, options)
    end

   # produit une édition pdf de Sheet avec les détails de lignes
    def to_detailed_pdf(options = {})
      options[:title] =  name.to_s
      Editions::DetailedSheet.new(@period, self, options)
    end

    def detailed_lines(page_number=1)
      total_general.fetch_lines(page_number)
    end

    def render_pdf
      to_pdf.render 
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