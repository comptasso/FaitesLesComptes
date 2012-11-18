# coding: utf-8

# Sheet permet de faire une édition de rubriks  avec un sous total
# Le but est de construire des sous parties de bilan ou de comtpe de résultats
# Les arguments sont period,
# le template qui est un fichier yml indiquant comment se font les
# regroupements des différents comptes le nom de ces rubriques.
#
# Voir la classe Compta::Rubrik
# Enfin le total_name permet de donner le nom du total de cette partie
#
# Par exemple Compta::Sheet.new(period, 'actif_immobilise.yml', 'TOTAL ACTIF IMMOBILISE - TOTAL 1'
#  
#
require 'yaml'

module Compta


  # Sheet pour bilan devrait être capable de lire un fichier yaml décrivant son organisation
  # avec les différentes rubriques.
  # De construire le tableau des lignes correspondantes
  # De vérifier que tous les comptes du bilan sont pris
  # De vérifier que le total de l actif et du passif sont égaux
  # De fournir les éléments à sheets controller
  # D'éditer un csv correspondant à ce bilan
  # d'imprimer les éléments en liste avec les détails des lignes (c'est donc une autre vue)
  #
  # Sheet se construit avec un exercice, un hash reprenant les informations et un doc (le nom du document)
  # Par exemple Compta::Sheet.new(p, @instructions[:actif], :actif)
  #
  class Sheet
    
attr_accessor :total_general, :sens, :doc


    def initialize(period, page, doc)
      @period = period
      @coll = page
      @doc = doc
      parse_file
      
    end

 def parse_file
   @sens = @coll[:sens]
   sous_totaux = @coll[:rubriks].map do  |k,v|
     puts "Inspection de v #{v.inspect}"
     list = v.map do |l, num|
       puts "clé : #{l}"
       puts "numeros : #{num}"
       Compta::Rubrik.new(@period, l, @sens, num)
     end
     Compta::Rubriks.new(@period, k, list)
   end

   @total_general = Compta::Rubriks.new(@period, @coll[:title] , sous_totaux)
 end
 
 def title
   @sens == :actif ? %w(Rubrique Brut Amort Net Précédent) : %w(Rubrique Montant Précédent)
 end

 # options est là pour permettre de préciser col_sep:"\t", cette option permet
 # d'éviter que les tableurs utilisent la virgule ce qui les perturbe en version
 # francisée.
 def to_csv(options = {col_sep:"\t"})
   CSV.generate(options) do |csv|
     csv << [@doc.capitalize] # par ex Actif
     csv << title  # la ligne des titres
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

 def to_index_csv(options = {col_sep:"\t"})
   CSV.generate(options) do |csv|
     csv << [@doc.capitalize] # par ex Actif
     csv << (@sens == :actif ? %w(Rubrique Brut Amort Net Précédent) : ['Rubrique', '', '',  'Montant', 'Précédent']) # la ligne des titres
     @total_general.collection.each do |rubs|
       rubs.lines.each do |l|

          csv << prepare_line(l)

        end

       csv << prepare_line(rubs.totals_prefix)
     end
     csv << prepare_line(@total_general.totals_prefix)

   end.gsub('.', ',') # remplacement de tous les points par des virgules
   # pour avoir la décimale dans le tableur
 end

 def prepare_line(line)
   if @sens != :actif
   line[1] = line[2]=''
   end
   line
 end


  end





end