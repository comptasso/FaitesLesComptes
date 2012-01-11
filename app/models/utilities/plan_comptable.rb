# coding: utf-8
class Utilities::PlanComptable

  def initialize(period_id)
    @pid=period_id
  end

 # crée des comptes à partir d'un fichier source
 # A terme d'autres type de sources seront possibles. Il faudra modifier
 # ou surcharger load_accounts
  def create_accounts(source)
    p=Period.find(@pid)
    nba=p.accounts.count # nb de comptes existants pour cet exercice
    t=self.load_accounts("#{Rails.root}/app/assets/plans/#{source}")
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

