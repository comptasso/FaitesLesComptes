# coding: utf-8

# la class Archive est destinée à stocker un exercice comptable
# et à le restaurer
class Admin::Archive

  attr_reader  :errors, :datas, :restores

  def initialize
    @errors=[]
    @restores={}
    @datas={}
  end
  # FIXME voir si psych permet de vérifier la validité du fichier
  def parse_file(archive)
    @datas = YAML.load(archive)
  rescue
    @errors << "Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"
  end

  # à partir d'un exercice, collect_data constitue un hash reprenant l'ensemble des données
  # de cet exercice
  def collect_datas(period)
    
    o=period.organism # l'organisme dont dépend period
    @datas[:organism]=o
    @datas[:period]=period
    @datas[:accounts]=period.accounts.all
    @datas[:destinations]=o.destinations.all
    @datas[:natures]=period.natures.all
    @datas[:bank_accounts]=o.bank_accounts.all
     # ici on a toutes les lignes dont la date est dans l'exercice
    @datas[:lines] =o.lines.period(period).all
     # On construit les ids des extraits bancaires référencés par des lignes de l'exercice
    be_ids= o.lines.period(period).select('DISTINCT(bank_extract_id)').where('bank_extract_id NOT NULL').all.map {|b| b.bank_extract_id}
# puis on ajoute à datas les extraits bancaires
    @datas[:bank_extracts]= be_ids.map {|be_id| BankExtract.find_by_id(be_id)}
    # La gestion des check_deposits est spécifique car il pourrait y avoir une remise de
    # chèques ayant des lignes à cheval sur 2 exercices
    cd_ids= @datas[:lines].map {|l| l.check_deposit_id}.reject {|r| r == nil }.uniq
    @datas[:check_deposits]= cd_ids.map {|cd_id| CheckDeposit.find_by_id(cd_id)}

    @datas[:cashes]=o.cashes.all
    @datas[:cash_controls]=o.cash_controls.for_period(period).all
    @datas[:books]=o.books.all

  

    

   

    # puis les lignes d'extrait à partir des extraits bancaires
    @datas[:bank_extract_lines]=[]
    @datas[:bank_extracts].each {|be| @datas[:bank_extract_lines] += be.bank_extract_lines.all}
    
   
    
  end

 
  def list_errors
    self.errors.all.join('\n')
  end

  def valid?
    self.errors.count == 0 ? true : false
  end

  # on cherche l'organisme concerné par l'archive
  def organism
    @datas[:organism]
  end


  def organism_exists?
    Organism.where('title = ? ', self.organism.title).nil? ? false : true
  end



  def info
    info=''
    info += "L'organisme n'existe pas et sera donc créé lors de le restauration" unless self.organism_exists?
    info += "L'organisme existe et ne sera pas modifié lors de le restauration" if self.organism_exists?
  end

  # utilisée pour recharger un nouvel organism dans une compta
  # TODO faire tout ceci dans une transaction en cas de problème
  def rebuild_organism
    # on crée l'oragnisme
    @restores[:organism] =Organism.create!(:title=>@datas[:organism].title, :description=>@datas[:organism].description)
    # on reprend les infos de period sauf organism_id
    pd=@datas[:period].attributes
    pd.delete 'organism_id' 
    @restores[:period] = @restores[:organism].periods.create!(pd)  # on crée le period

     self.rebuild(:accounts,:period, @restores[:period].id)
   

    # même manip pour destination sauf qu'il y a plusieurs destinations
    self.rebuild(:destinations, :organism, @restores[:organism].id) # destination

     # Les natures qui appartiennent à une période mais qui ont un lien avec un account
    @restores[:natures]= []
    @datas[:natures].each do |n|
      Rails.logger.debug n.inspect
      new_attributes=n.attributes
      
      new_attributes.delete 'id'
      Rails.logger.debug new_attributes
      if n.account_id
        bi= @datas[:accounts].index {|r| r.id == n.account_id}

        Rails.logger.debug "taille de restores : #{@restores[:accounts].size}"
       Rails.logger.debug "l'index du compte est #{bi} "
        new_attributes[:account_id]=@restores[:accounts][bi].id if bi
      end
      @restores[:natures] << Nature.create!(new_attributes)
    end


   
    self.rebuild(:bank_accounts,:organism, @restores[:organism].id) # bank_accounts


    @restores[:bank_accounts].each do |r| # les extraits bancaires
      self.rebuild(:bank_extracts, :bank_account, r.id)
    end

    @restores[:bank_extracts].each do |r|
      self.rebuild(:check_deposits, :bank_extract, r.id) # les remises de chèques
    end

   

    self.rebuild(:cashes, :organism, @restores[:organism].id)

    @restores[:cashes].each do |c|
      self.rebuild(:cash_controls, :cash, c.id)
    end

    self.rebuild(:books, :organism, @restores[:organism].id)


 @restores[:lines]=[]
    @datas[:lines].each do |l|
# l a un book_id, destination_id, nature_id, bank_account_id, check_deposit_id, bank_extract_id, cash_id
# il faut à chaque fois trouver le id d'origine et le id de destination
 new_attributes=l.attributes
 new_attributes.delete 'id'


new_attributes[:book_id]=substitute(l,:books) if l.book_id
new_attributes[:destination_id]=substitute(l,:destinations) if l.destination_id
new_attributes[:nature_id]=substitute(l,:natures) if l.nature_id
new_attributes[:bank_account_id]=substitute(l,:bank_accounts) if l.bank_account_id
new_attributes[:bank_extract_id]=substitute(l,:bank_extracts) if l.bank_extract_id
new_attributes[:cash_id]=substitute(l,:cashes) if l.cash_id
new_attributes[:check_deposit_id]=substitute(l,:check_deposits) if l.check_deposit_id
@restores[:lines] << Line.create!(new_attributes)

    end

  # Les lignes d'un extrait bancaire
    @restores[:bank_extract_lines]= []
    @datas[:bank_extract_lines].each do |bel|
      new_attributes=bel.attributes
      new_attributes.delete 'id'
      new_attributes[:bank_extract_id]=substitute(bel,:bank_extracts) if bel.bank_extract_id
      new_attributes[:check_deposit_id]=substitute(bel,:check_deposits) if bel.check_deposit_id
      new_attributes[:line_id]=substitute(bel,:lines) if bel.line_id
      @restores[:bank_extract_lines] << BankExtractLine.create!(new_attributes)
    end

    
   

  end

def substitute(inst, sym_model)
  sym_model_id=sym_model.to_s.singularize + '_id'
  bi=@datas[sym_model].index {|r| r.id == inst.instance_eval(sym_model_id)}
  @restores[sym_model][bi].id
end

  protected
# attribute est un symbole qui renvoie à ce qu'on cherche à reconstituer
# parent est un autre symbole indiquant le parent
# rebuild remplit le restores[:attribute] qui est un Array,
# rebuild est utile pour construire les dépendances du type has_many - belongs_to
  def rebuild(attribute, parent, parent_id)
    @restores[attribute]=[]
    @datas[attribute].each do |a|
    aa=a.attributes
    aa[parent.to_s  + '_id']=parent_id
    @restores[attribute] <<  attribute.to_s.capitalize.singularize.camelize.constantize.create!(aa)
    end

  end


end
