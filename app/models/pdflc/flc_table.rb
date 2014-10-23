#coding: utf-8

module Pdflc
  
  # La classe FlcTable est capable de fournir une série de lignes
  # à partir d'une requête.
  # 
  # Une FlcTable fonctionne avec une requête, un numéro de page, le nombre
  # de lignes par page,
  # et les colonnes à additionner.
  # 
  #  On peut aussi prendre en compte les champs à recueillir, ce qui peut-être 
  #  utile lorsque l'on fait un select * alors qu'on ne veut que quelques 
  #  champs.  
  # 
  # Une FlcTable doit savoir faire le total de ces colonnes et les 
  # transmettre
  # 
  class FlcTable
    
    attr_reader :columns_to_totalize, :fields
    
    def initialize(query,  page, nb_lines_per_page,
        columns_to_totalize = [], fields = [])
      @query = query
      @page = page
      @nb_lines_per_page = nb_lines_per_page
      @columns_to_totalize = columns_to_totalize
      @fields = fields
    end
    
    def lines
      @lines ||= fetch_lines
    end
    
    # les lignes préparées sont la transformation des champs à additionner 
    # en champ décimaux
    def prepared_lines
      
    end
    
    # renvoie un array de Decimal, correspondant aux champs qui sont à totaliser
    def totals
      
    end
    
    protected
    
    # ici on exécute la query avec le nombre de lignes demandées et l'offset
    # renvoyant à la page souhaitée
    def fetch_lines
      # query.offset.limit
      # puis préparation des lignes
    end
    
  end
  
end
