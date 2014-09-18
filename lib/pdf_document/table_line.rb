# coding: utf-8

module PdfDocument
  
  # Une TableLine est destinée à remplacer les simples Arrays utilisés pour
  # l'édition des tables des pdf. 
  # L'objectif est de pouvoir spécialiser ces lignes pour intégrer dans une 
  # table des sous totaux. 
  # 
  # La classe peut également mettre en forme elle-même les valeurs numériques au
  # format demandé
  #
  # Une TableLine doit 
  # - avoir un tableau de valeurs
  # - un tableau de types (avec le même nombre de colonnes)
  # 
  # Une TableLine peut avoir des options 
  # - subtotal:true indique qu'il s'agit d'une ligne de sous total qu'il ne 
  # faudra donc pas prendre en compte dans la totalisation de la table
  # - depth donne une profondeur de ligne permettant de les styler 
  # 0 est maigre, 1 en gras, 2 en plus gras encore (utilisé dans Rubriks.pdf.prawn
  # pour styler les différentes lignes d'une liasse.
  # 
  class TableLine 
    
    attr_reader :values, :types, :options, :depth
    
    def initialize(values, types, options={})
      @values = values
      @types = types
      @options = options
      @depth = options[:depth] || (subtotal? ? 1 : 0)
    end
    
    # appelle les méthodes adéquates pour chacun des éléments de la lignes
    # A surcharger lorsqu'on veut faire un traitement de la ligne
    # Par défaut applique number_with_precision à toutes les valeurs numériques
    def prepared_values
      values.collect.with_index do |v, i|
        types[i] == 'Numeric' ? french_format(v) : v 
      end
    end
    
    def subtotal?
      options[:subtotal]
    end
    
    protected
    
    def french_format(num)
      ActionController::Base.helpers.number_with_precision(num, :precision=>2)
    end
    
  end  
  
end
