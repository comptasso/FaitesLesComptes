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
    
    attr_reader :columns_to_totalize, :fields, :date_fields
    attr_accessor :arel
    
    def initialize(arel, nb_lines_per_page, fields,
        columns_to_totalize = [], date_fields = [])
      @arel = arel
      @page_number = 1
      @nb_lines_per_page = nb_lines_per_page
      @fields = fields
      @columns_to_totalize = columns_to_totalize
      @date_fields = date_fields
    end
    
    def lines
      @lines ||= fetch_lines
    end
    
    # change la requête, ce qui permet de garder le même objet pour l'ensemble
    # des listings du grand livre.
    def change_arel(ar)
      self.arel = ar
      @lines = nil
      @prepared_lines = nil
      @page_number = 1
    end
    
    # les lignes préparées sont la transformation des champs à additionner 
    # en champ décimaux
    def prepared_lines
      # appelle les méthodes adéquates pour chacun des éléments de la lignes
    # A surcharger lorsqu'on veut faire un traitement de la ligne
    # Par défaut applique number_with_precision à toutes les valeurs numériques
    
      @prepared_lines ||= lines.collect do |l|
        @fields.collect.with_index do |f, i| 
          v = l.send(f)
          v = french_format(v) if i.in?(columns_to_totalize)
          v = I18n.l(v.to_date, format:'%d-%m-%Y') if i.in?(date_fields)
          v ||= '' # pour gérer les nil
          v
        end
      end
    
    end
    
    # renvoie un array de Decimal, correspondant aux champs qui sont à totaliser
    def totals
      columns_to_totalize.collect do |i|
        lines.to_a.sum {|l| l.send(fields[i].to_sym) }
      end
    end
    
    # permet de passer à la page suivante; incrémente le numéro de page
    # et remet à nil les variables caches des lignes et des lignes préparées
    def next_page
      @page_number += 1
      @lines = nil
      @prepared_lines = nil
    end
    
    # renvoie le nombre de page; au minimum 1
    def nb_pages
      [(@arel.count.to_f/@nb_lines_per_page).ceil , 1].max
    end
    
    protected
    
    # ici on exécute la query avec le nombre de lignes demandées et l'offset
    # renvoyant à la page souhaitée
    def fetch_lines
      limit = @nb_lines_per_page
      offset = (@page_number - 1)*@nb_lines_per_page
      @arel.offset(offset).limit(limit)
    end
    
    def french_format(num)
      ActionController::Base.helpers.number_with_precision(num, :precision=>2)
    end
    
  end
  
end
