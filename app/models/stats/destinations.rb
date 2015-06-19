# coding: utf-8

module Stats

  # la classe construit un tableau de statistiques sur les destinations
  # avec autant de colonnes que les destinations qui ont eu un mouvement
  # dans l'exercice. 
  # 
  # L'argument est period
  # 
  # Les données sont disponibles par des variables d'instance qui sont 
  # @title_line, @lines et @total_line
  # 
  # @dests donne les destinations qui sont reprises dans cette table.
  # 
  # La première colonne de la table est constituée de la liste des natures 
  # ordonnée par livre et position.
  # 
  # Les méthode #to_csv (héritée de la classe Statistics) permet l'export.
  # TODO à vérifier
  # TODO voir pour pouvoir filtrer sur un jeu de destinations
  # TODO on pourrait aussi donner plus de flexibilité sur les dates. 
  # TODO faire les tests
  # 
  # #to_pdf n'est pas défini car le nombre fluctuant de destinations ne permet 
  # pas de faire la mise en page. 
  # TODO On pourrait bien sûr grouper par 12 pour 
  # utiliser le même type de mise en page que pour StatsNatures.
  # 
  class Destinations < Statistics
    
    attr_reader :title_line, :dests,  :lines, :total_line
    
    def initialize(period, options = {})
      super(period)
      @sector = options[:sector] || Sector.first
      @books =  @sector.books.order(:type)
      @dests = find_destinations
      @title_line = title
      @lines = dest_statistics.map {|r| [r.name] + table(r.dest_vals)}
      @total_line = totals
    end
    
    # retourne la ligne de titre 
    def title
      t = ['Natures']
      t += dests.collect(&:name) 
      t << 'Total' 
    end

     
    
    def to_pdf
      raise NotImplementedError, 'car le nombre de colonnes n\'est pas fixe.'
      # Editions::Stats.new(@period, self)
    end
    
    
    # Les lignes sont composées d'une première colonne avec un nom et de 
    # x colonnes de valeurs. 
    # La méthode crée la ligne de total, en sommant par colonne, 
    # convertit ces totaux en BigDecimal puis insère le 
    # premier champ Total. 
    def totals
      return ['Total'] if lines.empty?
      x = (lines.first.size) -1      
      tots = (1..x).collect { |i| (lines.sum {|l| l[i] }).to_d }
      tots.unshift 'Total'
      tots
    end
    
    
    
       
   
    
    protected
    
    
    
    
    # Renvoie un array dont les champs sont book_id, position, nature_id 
    # nature_name suivi du json dest_vals.
    # Les natures sont classées dans l'ordre des livres avec ensuite l'ordre 
    # des positions.
    # 
    # Le array de valeurs (dest_vals) est au format json avec 'f1' comme clé 
    # pour l'id de la destination et 'f2' comme clé pour la valeur du solde  
    
    def dest_statistics
      sql = <<EOF

SELECT book_id, position,  natures.id, natures.name, 

array_to_json(array_agg(ROW(destination_id, montant) ORDER BY destination_id))
AS dest_vals
FROM
(SELECT  destination_id, nature_id, sum(credit) -sum(debit) AS montant
FROM compta_lines
LEFT JOIN writings ON writings.id = compta_lines.writing_id 
WHERE writings.date >= ? AND writings.date <= ?  AND nature_id IS NOT NULL 
GROUP BY destination_id, nature_id ORDER by destination_id) AS ROW 

LEFT JOIN natures ON natures.id = nature_id
WHERE row.nature_id = nature_id AND book_id IN (?)
GROUP BY book_id, position, natures.id, name ORDER BY book_id, position
    
    
EOF
      res = Nature.find_by_sql([sql, 
          @period.start_date, @period.close_date,
          @books.collect(&:id)])
      res
      
      
    end
    
    
    # à partir d'une table de valeur, on doit prendre la liste des destinations
    # Il faut gérer le cas où toutes les écritures sont avec une destinations
    # et donc il n'y a pas besoin d'une colonne additionnelle
    # ainsi que celui où à l'inverse, aucune écriture n'a de destinations, et 
    # où il n'y a donc qu'une seule colonne Aucune
    def table(hash_vals)
      
      ids = dests.collect(&:id).reject(&:nil?)
      sup = ids.max || 0 # cas ou on a aucune dest avec un id
      if @additional_column
        ids << (sup+1) # pour intégrer la colonne Aucune
        # si la destination n'a pas été utilisée, on a des nil
        hash_vals.last['f1']= (sup+1) if  hash_vals.last['f1'] == nil
      end
      # définition de la taille du tableau
      taille = @additional_column ? (ids.max) + 1 : ids.max
      # que l'on créé      
      valeurs = Array.new(taille,0) 
      # pour chaque destination recherchée on cherche l'item qui a cet id en 
      # f1 et on récupère le montant en f2
      hash_vals.each {|f| valeurs[f['f1']] = f['f2'] } 
      # ici valeurs est un array avec trop de valeurs puisqu'on a toutes les 
      # destinations existant et pas seulement celles avec des mouvements
      val_sel = ids.collect {|id| valeurs[id]}
      # reste à totaliser
      val_sel << val_sel.sum.to_d # pour avoir un big_decimal
      val_sel
    end
    
    
    # retourne une table reprenant les id et noms des destinations qui ont 
    # été mouvementées pendant l'exercice.
    # 
    # La dernière destination est nil
    # et on en change le nom pour remplacer par aucune
    def find_destinations
      sql = <<EOF
      SELECT DISTINCT destinations.id, name FROM 
compta_lines LEFT JOIN destinations ON destinations.id = destination_id
LEFT JOIN writings ON writings.id = writing_id

WHERE nature_id IS NOT NULL AND writings.date >= ? AND writings.date <= ?
AND book_id IN (?)
ORDER BY id     
EOF
      res = Destination.find_by_sql([sql,
          @period.start_date, @period.close_date,
          @books.collect(&:id)])
      # cas où la table est vide
      return res if res.empty?
      
      # Ajout ou non de la colonne Aucune
      # Si la dernière colonne est nil, 
      # on l'intitule alors Aucune; ceci gère le cas le plus fréquent
      # où il y a eu des écritures sans qu'on leur attache une activité
      # 
      # On mémorise ce choix dans la variable d'instance Additionnal Column
      # 
      if res.last.name
        @additional_column = false
      else
        @additional_column = true
        res.last.name ||= 'Aucune' 
      end
      
      res
    end
    
    
    
  end
end