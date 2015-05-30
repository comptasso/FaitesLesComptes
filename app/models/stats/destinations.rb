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
    
    def initialize(period)
      super
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
    # Le array de json est sous forme d'un hash avec 'f1' comme clé pour l'id 
    # de la destination et 'f2' comme clé pour la valeur du solde  
    # TODO voir ce que ça donne pour les comités d'entreprise avec 4 livres
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
WHERE row.nature_id = nature_id
GROUP BY book_id, position, natures.id, name ORDER BY book_id, position
    
    
EOF
      res = Nature.find_by_sql([sql, @period.start_date, @period.close_date])
      res
      
      
    end
    
    
    # à partir d'une table de valeur, on doit prendre la liste des destinations
    def table(hash_vals)
      # pour chaque destination recherchée on cherche l'item qui a cet id en 
      # f1 et on récupère le montant en f2
      ids = dests.collect(&:id).reject(&:nil?)
      sup = ids.max
      ids << (sup+1)
      # si la destination n'a pas été utilisée, on a des nil
      hash_vals.last['f1']= (sup+1) if  hash_vals.last['f1'] == nil
      valeurs = Array.new(((ids.max) +1),0)
      hash_vals.each {|f| valeurs[f['f1']] = f['f2'] } 
      # ici valeurs est un array avec trop de valeurs puisqu'on a toutes les 
      # destinations existant
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
WHERE nature_id IS NOT NULL AND writings.date >= ? AND writings.date < ?
ORDER BY id     
EOF
      res = Destination.find_by_sql([sql, @period.start_date, @period.close_date ])
      # cas où la table est vide
      return res if res.empty?
      res.last.name ||= 'Aucune' # si la dernière colonne est nil, 
      # on l'intitule alors Aucune; ceci gère le cas le plus fréquent
      # où il y a eu des écritures sans qu'on leur attache une activité
      res
    end
    
    
    
  end
end