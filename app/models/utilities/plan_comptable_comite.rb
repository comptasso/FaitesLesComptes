# La particularité du plan comptable comité est d'être sectorisé
# D'où la nécessité de redéfinir create_accounts
class Utilities::PlanComptableComite < Utilities::PlanComptable
  
  # ici on n'a pas besoin du statut
  def initialize(period)
    @status = 'comite'
    @period = period
    @asc_id = period.organism.sectors.where('name LIKE ?', 'ASC').first.id
    @fonc_id = period.organism.sectors.where('name LIKE ?', 'Fonctionnement').first.id
  end
  
  # crée des comptes à partir d'un fichier source
  # A terme d'autres type de sources seront possibles. Il faudra modifier
  # ou surcharger load_accounts
  def self.create_accounts(period)
    new(period).create_accounts
  end
  
  def create_accounts 
    nba = period.accounts.count # nb de comptes existants pour cet exercice
    fichier = "#{source_path}/#{FICHIER}"
    y = YAML::load_file(fichier)
    y.each do |k, accs|
    sid = find_sector_id(k)      
 
    accs.each do |a|
      
      acc = period.accounts.new(a)
      acc.sector_id = sid
      Rails.logger.warn "#{acc.number} - #{acc.title} - #{acc.errors.messages}" unless acc.valid?
      acc.save 
    end
    end
    nb_comptes_crees = period.accounts(true).count - nba
    Rails.logger.debug "Création de #{nb_comptes_crees} comptes"
    return nb_comptes_crees # renvoie le nombre de comptes créés
   
  rescue Errno::ENOENT # cas où le fichier n est pas trouvé
    Rails.logger.warn("Erreur lors du chargement du fichier #{source_path}")
    return 0
  rescue Psych::SyntaxError # cas où le fichier est mal formé
    Rails.logger.warn("Erreur lors de la lecture du fichier #{source_path}")
    return 0
    
  end
  
  protected
  
  def find_sector_id(name)
   
    case name
    when 'no_sector' then nil
    when 'ASC' then @asc_id
    when 'Fonctionnement' then @fonc_id
    end
  end
  
  
  
  
end