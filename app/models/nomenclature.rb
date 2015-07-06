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
  
  # s'appuie sur resultats pour pouvoir gérer le cas des comités d'entreprise
  def resultat
    resultats.first rescue nil
  end
  
  # Pour les comités d'entreprise, il peut y avoir plusieurs résultats
  # résultat ASC et résultat FONC
  def resultats
    folios.where('name LIKE ?', 'resultat%')
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
        
        f = folios.new(:name=>k, :title=>v[:title], sens:v[:sens])
        fill_sector_id(f, v[:sector]) if v[:sector]
        f.save!
        f.fill_rubriks_with_position(v[:rubriks])
      end
    end
  end
  
  # Méthode remplissant les valeurs des rubriques pour l'exercice donné
  # avec les valeurs bruts, amortissement, net et previous_net.
  # 
  #  Quand on démarre l'appel au job, on met le champ job_finished_at à nil 
  #
  def fill_rubrik_with_values(period)
    Delayed::Job.enqueue Jobs::NomenclatureFillRubriks.new(organism.database_name,
      period.id)
    update_attribute(:job_finished_at, nil) 
  end
  
  # Indique si les valaurs des rubriques ont été remplies
  def rubrik_values_filled?
    job_finished_at.present?  
  end
  
  # indique si les rubriques ont été fraichement remplies en les comparant 
  # avec la date de modification de la table des ComptaLine.
  #
  # Si les rubriques ne sont pas fraiches, alors remet le champ job_finished_at
  # à nil; ce qui permettra ensuite au controller de constater plus vite que 
  # le travail de mise à jour n'est pas encore fini. Sachant que celui-ci est 
  # effectué en tâche de fond.
  # 
  # Gère le cas où il n'y a pas encore de ComptaLine
  def fresh_values?
    return false unless job_finished_at 
    # donc un calcul a été fait mais est-il récent ?
    derniere_ecriture = ComptaLine.maximum(:updated_at)
    dernier_compte = Account.maximum(:updated_at)
    
    return true unless derniere_ecriture # oui car pas d'écriture
    fresh = derniere_ecriture < job_finished_at &&  dernier_compte < job_finished_at 
    # une écriture au moins a été modifiée après la construction des données
    # du coup on met le champ job_finished_at à nil puisque c'est l'existence
    # d'une valeur qui va définir si le travail est fini.
    update_attribute(:job_finished_at, nil) unless fresh
    fresh
  end
  
  
 
  # crée une instance de Compta::Nomenclature pour l'exercice demandé;
  # cela permet de valider que la nomenclature est correcte par rapport aux comptes
  # de l'exercice en question
  def compta_nomenclature(period)
    Compta::Nomenclature.new(period, self)
  end
  
  # création d'un document à partir du folio demandé
  # et de 'exercice
  def sheet(period, folio)
    Compta::Sheet.new(period, folio) 
  end
  
  
  # indique si une nomenclature est cohérente et donc utilisable pour produire des
  # états comptables.
  # Utilité dans SheetsController pour vérifier que la nomenclature est cohérente
  # TODO introduire un niveau de contrôle moins complet pour traiter 
  # uniquement ce qui doit l'être lors d'un ajout ou suppression de compte.
  def coherent?
    Utilities::NomenclatureChecker.new(self).valid?
  end
  
  protected
  
  def trouve_sector_id(sector_name)
    return nil unless sector_name
    organism.sectors.where('name = ?', sector_name).first.id    
  end
  
  def fill_sector_id(folio, sector_name)
    return unless sector_name
    folio.sector_id = trouve_sector_id(sector_name)
  end
  
  
  
      
           

end