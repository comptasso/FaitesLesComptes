# coding: utf-8

# la class Archive est destinée à stocker un exercice comptable
# et à le restaurer
class Admin::Archive

  attr_reader :arch, :errors, :datas

  def initialize
    @errors=[]
  end
  # FIXME voir si psych permet de vérifier la validité du fichier
  def parse_file(archive)
    @arch = YAML.load(archive)
  rescue
    @errors << "Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"
  end

  # à partir d'un exercice, collect_data constitue un hash reprenant l'ensemble des données
  # de cet exercice
  def collect_datas(period)
    @datas={}
    o=period.organism # l'organisme dont dépend period
    @datas[:organism]=o
    @datas[:period]=period
    @datas[:destinations]=o.destinations.all
    @datas[:natures]=period.natures.all
    @datas[:bank_accounts]=o.bank_accounts.all
    @datas[:cashes]=o.cashes.all
    @datas[:cash_controls]=o.cash_controls.for_period(period).all
    @datas[:books]=o.books.all
 # ici on a toutes les lignes dont la date est dans l'exercice
    @datas[:lines] =o.lines.period(period).all
  

    # La gestion des check_deposits est spécifique car il pourrait y avoir une remise de
    # chèques ayant des lignes à cheval sur 2 exercices
    cd_ids= @datas[:lines].map {|l| l.check_deposit_id}.reject {|r| r == nil }.uniq
    @datas[:check_deposits]= cd_ids.map {|cd_id| CheckDeposit.find_by_id(cd_id)}

    # On construit les ids des extraits bancaires référencés par des lignes de l'exercice
    be_ids= o.lines.period(period).select('DISTINCT(bank_extract_id)').where('bank_extract_id NOT NULL').all.map {|b| b.bank_extract_id}
# puis on ajoute à datas les extraits bancaires
    @datas[:bank_extracts]= be_ids.map {|be_id| BankExtract.find_by_id(be_id)}

    # puis les lignes d'extrait à partir des extraits bancaires
    @datas[:bank_extract_lines]=[]
     @datas[:bank_extracts].each {|be| @datas[:bank_extract_lines] += be.bank_extract_lines.all}
    
    @datas[:accounts]=period.accounts.all
    
  end

 
  def list_errors
    self.errors.all.join('\n')
  end

  def valid?
    self.errors.count == 0 ? true : false
  end

  # on cherche l'organisme concerné par l'archive
  def organism
    @arch[:organism]
  end


  def organism_exists?
    Organism.where('title = ? ', self.organism.title).nil? ? false : true
  end



  def info
    info=''
    info += "L'organisme n'existe pas et sera donc créé lors de le restauration" unless self.organism_exists?
    info += "L'organisme existe et ne sera pas modifié lors de le restauration" if self.organism_exists?
  end



end
