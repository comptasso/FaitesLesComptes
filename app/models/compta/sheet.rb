# coding: utf-8

# Sheet est destinées à éditer une liste de rubriks
# Le but est de construire des sous parties de bilan ou de comtpe de résultats
# Les arguments sont period, une page qui est une partie d'un fichier yml.
# Concrètement la classe Nomenclature lit un fichier nomenclature.yml.
#
# Le fichier a différentes parties : actif, passif, exploitation, ...
# Nomenclature a une méthode sheet qui crée un objet Sheet en transmettant
# period,  les informations nécessaires et le nom du document
#
# Exemple, extrait de nomenclature.yml
# :actif:                      -> le document
#    :title: Bilan Actif        -> son titre
#    :sens: :actif              -> son sens
#    :rubriks:                  -> la liste des rubriques   
#      :Immobilisations incorporelles:            -> première sous rubrique (ce sera une rubriks)
#        :Frais d'établissement: '201 -2801'       -> une rubrik
#        :Frais de recherche et développement: 203 -2803
#        :Fonds commercial#': 206 207 -2807 -2906 -2907
#        :Autres: 208 -2808 -2809
#      :Immobilisations corporelles:              -> deuxième sous rubrique
#
# Le document est donc composé de rubriks, eux même composé de rubrik
# Voir les classes correspondantes
# Voir la classe Compta::Rubrik
# 
# Dans initialize, les arguments sont recopiés, puis on appelle parse_page
# qui va parser les instructions du document demandé.
#
#
# #total_general est une méthode qui renvoie la rubriks principale de sheet
#
# sens permet de savoir si on est un document avec une logique d'actif ou de passif
# Cette logique permet en fait de choisir si les nombres credit ou débit sont positifs
# doc est le nom du document.
#  
#
require 'yaml'

module Compta

  class Sheet
    
    include Utilities::ToCsv
    
    attr_accessor :total_general, :sens, :name


    def initialize(period, page, name)
      @period = period
      @list_rubriks = page
      @name = name
      parse_page
     end


 # utilisé pour le csv de l'option show
 def to_csv(options = {col_sep:"\t"})
   CSV.generate(options) do |csv|
     csv << [@name.capitalize] # par ex Actif
     csv << entetes  # la ligne des titres
     @total_general.collection.each do |rubs|
       rubs.collection.each do |r|
         if (r.resultat?)
           retour = r.total_passif
           retour[0] = '12 - ' + retour[0].to_s
           csv << retour
         else
           r.lines.each {|l| csv << (@sens == :actif ? l.to_actif : l.to_passif)}
         end
       end
       csv << (@sens == :actif ? rubs.total_actif : rubs.total_passif)
     end
     csv << (@sens == :actif ? @total_general.total_actif : @total_general.total_passif)

   end.gsub('.', ',') # remplacement de tous les points par des virgules
   # pour avoir la décimale dans le tableur
 end

 def detail_to_csv(options = {col_sep:"\t"})
   CSV.generate(options) do |csv|
   csv <<  %w(Numéro Libellé Brut Amort Net Précédent)

   @period.two_period_account_numbers.each {|num| csv << Compta::RubrikLine.new(@period, :actif, num).to_csv} 
   end
   csv
 end

 def detail_to_xls
   detail_to_csv.encode("windows-1252")
 end



 # utilisé pour le csv de l'action index
 def to_index_csv(options = {col_sep:"\t"})
   CSV.generate(options) do |csv|
     csv << [@name.capitalize] # par ex Actif
     csv << (@sens == :actif ? %w(Rubrique Brut Amort Net Précédent) : ['Rubrique', '', '',  'Montant', 'Précédent']) # la ligne des titres
     @total_general.collection.each do |rubs|
       rubs.lines.each {|l| csv << prepare_line(l) }
       csv << prepare_line(rubs.totals_prefix)

     end
     csv << prepare_line(@total_general.totals_prefix)

   end.gsub('.', ',') # remplacement de tous les points par des virgules
   # pour avoir la décimale dans le tableur
 end
 
 def to_index_xls(options = {col_sep:"\t"})
   to_index_csv(options).encode("windows-1252")
 end

 protected

 # appelé par initialize, construit l'ensemble des rubriks qui seront utilisées pour
 # les différentes parties du document (avec à chaque fois le sous total affiché)
 # puis, utilise ces rubriques, pour faire le total_general
 def parse_page
   @sens = @list_rubriks[:sens]
   sous_totaux = @list_rubriks[:rubriks].map do  |k,v|
     puts "Inspection de v #{v.inspect}"
     list = v.map do |l, num|
       puts "clé : #{l}"
       puts "numeros : #{num}"
       Compta::Rubrik.new(@period, l, @sens, num)
     end
     Compta::Rubriks.new(@period, k, list)
   end

   @total_general = Compta::Rubriks.new(@period, @list_rubriks[:title] , sous_totaux)
 end

 # prepare line sert à effacer les montant brut et amortissement pour ne garder 
 # que le net.
 # Utile pour le passif d'un bilan et pour les comptes de résultats qui n'ont pas 
 # la même logique qu'une page actif
 def prepare_line(line)
   if @sens != :actif
   line[1] = line[2]=''
   end
   line
 end

 # prépare les entêtes utilisés pour le fichier csv
 def entetes
   @sens == :actif ? %w(Rubrique Brut Amort Net Précédent) : %w(Rubrique Montant Précédent)
 end


  end





end