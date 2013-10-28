# coding: utf-8



# Nomenclature est une classe intermédiaire entre Organism et Folio
# Les folios définissent les données permettant de construire un document 
# comme l'actif, passif, compte de résultats et bénévolat (et peut être d'autres
# plus tard).
# 
# Mais les folios ne sont pas totalement indépendant les uns des autres
# Par exemple actif et passif sont étroitement reliés. 
# 
# C'est Nomenclature qui, par ses méthodes check_validity, permet de vérifier
# la cohérence des folios. 
# 
# # Il ne faut pas confondre avec Compta::Nomenclature qui est un objet beaucoup
# plus concret puisqu'il est associé à un exercice (period) et que Compta::Nomenclature
# peut donc faire des contrôles sur la validité des éditions qui seront produites.
#
# Les validations ici ne concernent donc que la présence de l'organisme 
# 
# Mais coherent? ajoute une série de validations sur la présence des folios
# obligatoires (actif, passif et résultat) et appelle également coherent? sur 
# les folios puis contrôle enfin que les Compta::Nomenclatures sont également 
# cohérentes pour chacun des exercices.
#
#
#
class Nomenclature < ActiveRecord::Base 

  
  belongs_to :organism
  has_many :folios, dependent: :destroy
  has_many :rubriks, through: :folios

  validates :organism_id, :presence=>true
   
  def actif
    folios.where('name = ?', :actif).first rescue nil
  end
  
  def passif
    folios.where('name = ?', :passif).first rescue nil
  end
  
  def resultat
    folios.where('name = ?', :resultat).first rescue nil
  end
  
  def benevolat
    folios.where('name = ?', :benevolat).first rescue nil
  end
  
  # permet de lire un fichier yml représentant la nomenclature utilisée pour
  # la présentation des comptes en différentes rubriques.
  # La méthode lit le fichier puis crée les rubriks correspondantes.
  def read_and_fill_folios(filename)
    yml = YAML::load_file(filename)
    
    transaction do
      yml.each do |k,v|
        f = folios.create(:name=>k, :title=>v[:title], sens:v[:sens])
        f.fill_rubriks_with_position(v[:rubriks])
      end
    end
  end
  
  
 
  # crée une instance de Compta::Nomenclature pour l'exercice demandé;
  # cela permet de valider que la nomenclature est correcte par rapport aux comptes
  # de l'exercice en question
  def compta_nomenclature(period)
    Compta::Nomenclature.new(period, self)
  end
  
  def sheet(period, folio)
    Compta::Sheet.new(period, folio) 
  end

  # vérifie la validité de la nomenclature, laquelle repose sur l'existence 
  # de folios actif, passif et resultat.
  # 
  # Par ailleurs, chacun des folios doit être lui même valide.
  # 
  # Enfin on controle que toutes les Compta::Nomenclature sont coherent
  # pour tous les exercices de l'organism
  def check_coherent
    errors.add(:actif, 'Actif est un folio obligatoire') unless actif
    errors.add(:passif, 'Passif est un folio obligatoire') unless passif
    errors.add(:resultat, 'Resultat est un folio obligatoire') unless resultat
    
    if actif && passif
      bilan_balanced?  # tous les comptes C doivent avoir un compte D correspondant
      bilan_no_doublon? 
    end
    # reprise des validations propres aux folios
    # ce qui comprend le fait qu'un folio resultat ne doit avoir que des comptes 6 et 7
    # et qu'un folio benevolat ne peut avoir que des comptes 8
    folios.each do |f|
      errors.add(:folio, "Le folio #{f.name} indique une incohérence : #{f.errors.full_messages}") unless f.coherent?
    end
    
    organism.periods.opened.each { |p| period_coherent?(p) }
    
  end
  
  # indique si une nomenclature est cohérente et donc utilisable pour produire des
  # états comptables
  def coherent?
    check_coherent
    errors.any? ? false : true
  end
  
   protected
  # sert à vérifier que si on compte C est pris, on trouve également un compte D
  # et vice_versa.
  # Ajoute une erreur à :bilan si c'est le cas avec comme message la liste des comptes
  # qui n'ont pas de correspondant
  def bilan_balanced?
    return false unless actif && passif
    array_numbers = actif.rough_instructions + passif.rough_instructions
      
    # maintenant on crée une liste des comptes D et une liste des comptes C
    numbers_d = array_numbers.map {|n| $1 if n =~ /^(\d*)D$/}.compact.sort
    numbers_c = array_numbers.map {|n| $1 if n =~ /^(\d*)C$/}.compact.sort
    
    if numbers_d == numbers_c
      return true
    else
      d_no_c = numbers_d.reject {|n| n.in? numbers_c}
      c_no_d = numbers_c.reject {|n| n.in? numbers_d}
        
      self.errors[:bilan] << " : comptes D sans comptes C correspondant (#{d_no_c.join(', ')})" unless d_no_c.empty?
      self.errors[:bilan] << " : comptes C sans comptes D correspondant (#{c_no_d.join(', ')})" unless c_no_d.empty?
        
      return false
    end
  end
      
  def bilan_no_doublon?
    return false unless actif && passif
    array_numbers = actif.rough_instructions + passif.rough_instructions
    errors.add(:bilan, 'Une instruction apparait deux fois dans la construction du bilan') unless array_numbers.uniq.size == array_numbers.size
  end
  
  # vérifie que nomenclature est coherent pour une période donnée en 
  # créant Compta::Nomenclature; puis recopie les erreurs s'il y en a
  def period_coherent?(period)
    cn = compta_nomenclature(period)
    validity = cn.valid?
    cn.errors.each { |k, err| errors.add(k, err) } unless validity
    validity
  end  
  
      
           

end