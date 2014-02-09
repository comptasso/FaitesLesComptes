# coding: utf-8

# Plan Comptable est une classe rattachée à un exercice
# qui permet de lire un fichier yml et de créer les comptes pour l'exercice concerné
# 
# Le premier argument de initialize est le period, le second le statut de l'organisme
#
# Le fichier yml fournissant les informations de compte s'appelle obligatoirement 'plan_comptable.yml'
# et doit être placé dans le répertoire app/assets/parametres/#{status}, ou status
# est le statut de l'organisme (actuellement Association ou Entreprise, mais cette liste sera surment étendue ultérieurement)
#
# La méthode de clase self.create_accounts est essentiellement la seule utilisée, en
# l'occurence dans le callback create_plan de period.
#
class Utilities::PlanComptable

  FICHIER = 'plan_comptable.yml'
  
  attr_reader :period, :status

  def initialize(period, status)
    @period = period
    @status = status.downcase
  end

  
  # crée des comptes à partir d'un fichier source
  # A terme d'autres type de sources seront possibles. Il faudra modifier
  # ou surcharger load_accounts
  def self.create_accounts(period, status)
    pc = new(period, status)
    pc.create_accounts
  end
  
  # crée des comptes pour une caisse ou une banque pour tous les exercices ouverts
  # méthode appelée par after_create des modèles Cash et BankAccount
  def self.create_financial_accounts(finance)
    racine  = finance.class.compte_racine # donc normalement 512 ou 53
    new_number = Account.available(racine)
    
    ps = finance.organism.periods.opened
    ps.each do |p|
      new_acc = finance.accounts.new(number:new_number, title:finance.nickname)
      new_acc.period_id = p.id
      new_acc.save!
    end
  end

  def create_accounts
    nba = period.accounts.count # nb de comptes existants pour cet exercice
    t = load_accounts
    # TODO gérer ces questions par des erreurs et non par des tests
    if t && !(t.is_a?(String)) # si load_accounts a renvoyé la chaine 'Erreur...
      t.each do |a|
        acc = period.accounts.new(a)
        Rails.logger.warn "#{acc.number} - #{acc.title} - #{acc.errors.messages}" unless acc.valid?
        acc.save 
      end
      nb_comptes_crees = period.accounts(true).count - nba
      Rails.logger.debug "Création de #{nb_comptes_crees} comptes"
      return nb_comptes_crees # renvoie le nombre de comptes créés
    else
      Rails.logger.warn("Erreur lors du chargement du fichier #{source_path}")
      return 0
    end
  end
  
  # prend les comptes de from_period et crée les comptes correspondants pour period
  # TODO introduire la copie des seuls comptes utilisés
  def copy_accounts(from_period)
    Period.transaction do
      from_period.accounts.each do |acc|
        bcc = acc.dup
        bcc.period_id = period.id
        bcc.save
      end
    end
  end

  protected

  def source_path
    "#{Rails.root}/app/assets/parametres/#{status}/#{FICHIER}"
  end
  
  def load_accounts
    YAML::load_file(source_path)
  rescue 
    "Erreur lors du chargement du fichier #{status}"
  end
end

