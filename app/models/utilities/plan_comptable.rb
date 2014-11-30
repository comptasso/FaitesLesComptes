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

  # OPTIMIZE : on pourrait faire status = nil lorsque le period est persistant
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
  
  # recopie les natures de l'exercice précédent 's'il y en a un) 
  def copy_natures(from_period)
    from_period.natures.all.each do |n|
      nn = {name: n.name, comment: n.comment, book_id: n.book_id} # on commence à construire le hash
      if n.account_id # cas où il y avait un rattachement à un compte
        previous_account=from_period.accounts.find(n.account_id) # on identifie le compte de rattachement
        nn[:account_id] = period.accounts.find_by_number(previous_account.number).id # et on recherche son correspondant dans le nouvel exercice
      end
      period.natures.create!(nn) # et on créé maintenant une nature avec les attributs qui restent
    end
  end
  
   # crée le compte de remise de chèques
  # TODO faire spec d'intégration
  def create_rem_check_accounts
      period.accounts.create!(REM_CHECK_ACCOUNT)
  end
  
  
  
  # crée les comptes de banques et de caisse lorsqu'il n'y a pas d'exercice 
  # précédent
  def create_bank_and_cash_accounts
    organism = period.organism
    # organisme a créé une banque et une caisse par défaut et il faut leur créer des comptes
    # utilisation de send car create_accounts est une méthode protected
    organism.bank_accounts.each {|ba| ba.send(:create_accounts)}
    organism.cashes.each {|c| c.send(:create_accounts)}
    period.accounts(true) # pour mettre à jour la relation avec les comptes
    # sinon une création et une destruction dans la foulée (cas des tests) laisse une trace de ces deux comptes
  end
  
  
  # load natures est appelé lors de la création d'un premier exercice
  # load_natures lit le fichier natures_asso.yml et crée les natures correspondantes
  # retourne le nombre de natures
  #
  # TODO améliorer la gestion d'une éventuelle erreur
   def load_natures  
    Rails.logger.debug 'Création des natures'
    nats = load_file_natures
    books = collect_books(nats)
    nats.each do |n|
      a = period.accounts.find_by_number(n[:acc]) 
       nat = period.natures.new(name:n[:name], comment:n[:comment], account:a)
       nat.book_id = books[n[:book]] 
       puts "#{nat.name} - #{nat.errors.messages}" unless nat.valid?
       nat.save
    end
    period.natures(true).count
  end
  
   
    # TODO voir comment gérer les exceptions
  # remplit les éléments qui permettent de faire le pont entre le module 
  # Adhérents (et plus précisément, sa partie Payment) et le PaymentObserver
  # qui écrit sur le livre des recettes.
  def fill_bridge
    period.organism.fill_bridge
  end


 
  
  
  
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
  
   def load_file_natures(source = nil)
    source = "#{Rails.root}/app/assets/parametres/#{status.downcase}/natures.yml"
    YAML::load_file(source)
  rescue
    Rails.logger.warn "Erreur dans le chargement du fichier #{source}"
    []
  end
  
   # fait la collecte des livres qui sont nécessaires à la création des natures
  def collect_books(natures)
    livres = natures.collect {|n| n[:book]}.uniq
    hash_books = {}
    livres.each do |b|
      hash_books[b] = period.organism.books.where('title = ?', b).first.id
    end
    hash_books
  end
  
  
end

