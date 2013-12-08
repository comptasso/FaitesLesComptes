# coding: utf-8

require 'editions/sheet'


module Editions


  # DetailedSheet permet la production de fichier pdf avec le détail des
  # comptes permettant à l'utilisateur de visualiser quels sont les comptes 
  # pris pour calculer un Sheet,
  # que ce soit compte de résultats, actif, passif ou bénévolat
  class DetailedSheet < Editions::Sheet

     # Le pdf se débrouille cependant tout seul pour couper le tableau et faire la numérotation
    # car il n'y a pas de sous totaux affichés en bas des pages. 
    # 
    # # FIXME il y a cependant un problème avec le fond provisoire qui n'est mis que 
    # sur la dernière page

    def fetch_lines(page_number = 1) 
      @source.fetch_lines(page_number)
    end

    

  end

end