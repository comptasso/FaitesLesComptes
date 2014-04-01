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
# La méthode de clase self.create_accounts est appelée par le callback 
# create_plan de period pour le premier exercice d'une compte.
# 
# Une autre méthode copy_accounts est appelée pour la création des comptes 
# d'un exercice à partir de ceux de l'exercice précédent.
# 
# De même #create_financial_accounts est appelée par le callback after_create
# des modèles Bank et Cash
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
    new(period, status).create_accounts
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

  
  # prend les comptes de from_period et crée les comptes correspondants pour period
  # s'ils sont marqués comme utilisé dans l'exercice d'origine
  def copy_accounts(from_period)
    Period.transaction do
      from_period.accounts.where('used = ?', true).each do |acc|
        bcc = acc.dup
        bcc.period_id = period.id
        bcc.save
      end
    end
  end

 
  
  
  
  # create_accounts est appelé par un callback de Period lors de la création d'un 
  # premier exercice. 
  # 
  # create_accounts lit le fichier yml du plan comptable correspondant au statut de 
  # l'organisme, puis crée les comptes lus dans ce fichier. 
  # 
  # Il compte le nombre de compte avant la création (il pourrait y avoir des comptes de 
  # banques et de caisse, si jamais l'ordre des callbacks était changé dans Period.
  # 
  # La méthode renvoie le nombre de comptes créés. 
  # 
  # Deux exceptions sont capturées, celle où le fichier n'existe pas et celle où
  # le fichier est mal formé.
  #
  def create_accounts
    nba = period.accounts.count # nb de comptes existants pour cet exercice
    t = YAML::load_file(source_path)
    t.each do |a|
      acc = period.accounts.new(a)
      Rails.logger.warn "#{acc.number} - #{acc.title} - #{acc.errors.messages}" unless acc.valid?
      acc.save 
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

  def source_path
    "#{Rails.root}/app/assets/parametres/#{status}/#{FICHIER}"
  end
  
  
end

