# coding: utf-8

require 'editions/sheet'


module Editions


  # DetailedSheet permet la production de fichier pdf avec le détail des
  # comptes permettant à l'utilisateur de visualiser quels sont les comptes 
  # pris pour calculer un Sheet,
  # que ce soit compte de résultats, actif, passif ou bénévolat
  class DetailedSheet < Editions::Sheet

    

    def fetch_lines(page_number = 1)
      set_columns
      @source.detailed_lines(page_number)
    end

    

  end

end