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


  # Sheet est une classe qui prend
  #
  class Sheet

    
  end

end