# coding: utf-8

# Plan Comptable est une classe rattachée à un exercice
# qui permet de lire un fichier yml et de créer les comptes pour l'exercice concerné
class Utilities::PlanComptable

  
 # crée des comptes à partir d'un fichier source
 # A terme d'autres type de sources seront possibles. Il faudra modifier
 # ou surcharger load_accounts
  def create_accounts(period_id, source)
    p=Period.find(period_id)
    nba=p.accounts.count # nb de comptes existants pour cet exercice
    t=self.load_accounts("#{Rails.root}/app/assets/parametres/#{source}")
    raise 'Erreur lors du chargement du fichier' if t.is_a?(String)
    t.each {|a| p.accounts.create(a)}
    p.accounts.count-nba # renvoie le nombre de comptes créés
  end

  protected
  
  def load_accounts(source)
    YAML::load_file(source) 
  rescue
    "Erreur lors du chargement du fichier #{source}"
  end
end

