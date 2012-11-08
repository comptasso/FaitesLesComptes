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
  # D'éditer un pdf correspondant à ce bilan
  # d'imprimer les éléments en liste avec les détails des lignes (c'est donc une autre vue)
  #
  class Sheet
    
attr_accessor :total_general

 def initialize(period, template)
      @period = period
      @coll = YAML::load_file(File.join Rails.root, template)
      parse_file
      
    end

 def parse_file
   sens = @coll[:sens]
   sous_totaux = @coll[:rubriks].map do  |k,v|
     puts "Inspection de v #{v.inspect}"
     list = v.map do |l, num|
       puts "clé : #{l}"
       puts "numeros : #{num}"
       Compta::Rubrik.new(@period, l, sens, num)
     end
     Compta::Rubriks.new(@period, k, list)
   end

   @total_general = Compta::Rubriks.new(@period, 'Total General', sous_totaux)
 end
#-
#-    # retourne le tableau des lignes, avec les titres des trubriques et
#-    # les sous totaux de ces rubriques.
#-    # met à jour le total
#-    def render
#-      return @tableau unless @tableau.empty?
#-      @t1 = @t2 = 0 # pour éviter qu'un double appel à render ne vienne cumuler les totaux
#-      @rubriks.each do |rubrik|
#-         r = Compta::Rubrik.new(@period, rubrik[:title], rubrik[:numeros])
#-         @tableau << [rubrik[:title]]
#-         @tableau += r.values
#-         totals = r.totals
#-         cumul(totals) # mise à jour des totaux
#-         @tableau << totals
#-       end
#-       @tableau
#-    end

    
  end

end