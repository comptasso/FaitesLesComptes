# coding: utf-8


# TODO # ajouter une vérification dans la reconstruction (du type nb d'objects total et montant des lignes
# TODO ?ajouter un checksum md5 pour empêcher les modifs externes
#
# Archive est le modèle qui permet de faire la sauvegarder et la restauration
# d'une comptabilité entière.
# La restauration se fait par parse_file(archive) qui construit la variable
# d'instance @datas, utilisée ensuite pour reconstruire l'ensemble des enregistrements
#
# Ne pas oublier de modifier la liste des modèles dans initializers/constants.rb
# et de redémarrer le serveur après cette modification
class Archive < ActiveRecord::Base

   
  belongs_to :organism
  
  attr_reader :collect

   # à partir d'un exercice, collect_data constitue un hash reprenant l'ensemble des données
  # de cet exercice
  def collect_datas
    @collect= {}
    @collect[:comment] = self.comment
    @collect[:created_at] = self.created_at
    @collect[:organism] = self.organism
    MODELS.each do |m|
      @collect[m.pluralize.to_sym] = organism.instance_eval(m.pluralize).all
    end
    # collecte des infos de la table HABTM bank_extract_line_line
    # ces informations sont stockées sous la forme d'un tableau de hash
    bel_lines = []
    organism.bank_extract_lines.each do |bel|
      bel.lines.each  { |l|  bel_lines  <<   {:bank_extract_line => bel.id, :line => l.id}  }
    end
    @collect[:bank_extract_lines_lines] = bel_lines
  end

  # affiche le titre de l'archive à partir de l'organisme et de la date de création
  def title
    (organism.title + ' ' + created_at.to_s).split.join('_')
  end

  # une instance d'archive peut recréer une compta à partir du fichier chargé
  def restore_compta(archive)
    @restored_compta = Restore::RestoredCompta.new(archive)
  end

  
#
#  # après restore_compte, archive can give the list of original_datas
#  def load_datas(sym_model = nil)
#    raise 'la comptabilité n pas été reconstruite' unless @restored_compta
#    if sym_model
#      @restored_compta.datas_for(sym_model)
#    else
#      @restored_compta.datas
#    end
#
#  end

#  def restores(sym_model)
#    raise 'la comptabilité n pas été reconstruite' unless @restored_compta
#    r = @restored_compta.restores[sym_model]
#    if r && !r.empty?
#      r.records
#    end
#  end
#
#  def rebuild_all_records
#    @restored_compta.rebuild_all_records
#  end


  # TODO create_class ne semble plus utilisé - A supprimer ?
  # FIXME voir si psych permet de vérifier la validité du fichier

  # create_class permet de créer les classes recensées dans MODELS au cas où
  # celles ci ne sont pas déja chargées en mémoire. C'est le cas en tout
  # cas en développement
#  def create_class(class_name, superclass, &block)
#    klass = Class.new superclass, &block
#    Object.const_set class_name, klass
#  end


  # parse_file prend un fichier archive, charge les fichiers nécessaires
  # load et non require pour être certain de les recharger si nécessaire
  # et retourne les @datas
#  def parse_file(archive)
#    require 'yaml'
#    load('organism.rb')
#    MODELS.each do |model_name|
#      load(model_name + '.rb')
#    end
#    @datas = YAML.load(archive)
#  rescue  Psych::SyntaxError
#    errors[:base] = "Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"
#  end

 

  # donne la liste des erreurs
  def list_errors
    self.errors.messages.map { |k,m| m }.join('\n')
  end

  
  def organism_exists?
    Organism.where('title = ? ', self.organism.title).nil? ? false : true
  end

#  def rebuild_organism
#    Organism.transaction do
#        true
#    end
#    rescue ActiveRecord::RecordInvalid => invalid
#    Rails.logger.warn 'Erreur dans la reconstitution des données'
#    false
#  end

  # rebuild organism reconstruit l'ensemble de la hiérarchie des données et renvoie true si
  # succès, sinon renvoie false. L'ensemble est fait dans une transaction.
  # La création des données se fait notamment dans rebuild par un appel à create!
#  def rebuild_organism
#    Organism.transaction do
#      self.rebuild_organism_and_direct_children
#      @restores[:periods].each { |p| self.rebuild_period_and_children(p) } if @restores[:periods]
#      true
#    end
#
#  end



  protected

  # utilisée par rebuild_organism pour recharger un nouvel organism dans une compta
  # la méthode utilise skip_callback sur Organism, Period et Transfer pour éviter les
  # construction automatiques de données.
  # ne pas oublier de faire les set_callback à la fin
#  def rebuild_organism_and_direct_children
#    Organism.skip_callback(:create, :after ,:create_default)
#    a=@datas[:organism].attributes
#    a.delete 'id' # doit être fait en deux lignes car delete 'id' retourne l'id et non les attributs
#    @restores[:organism]= Organism.create!(a)
#
#    self.rebuild(:destinations, :organism, @restores[:organism].id)
#    self.rebuild(:bank_accounts,:organism, @restores[:organism].id)
#    @restores[:bank_accounts].each do |r| # les extraits bancaires
#      self.rebuild(:bank_extracts, :bank_account, r.id)
#    end
#    @restores[:bank_extracts].each do |r|
#      self.rebuild(:check_deposits, :bank_extract, r.id) # les remises de chèques
#    end
#    self.rebuild(:cashes, :organism, @restores[:organism].id)
#    @restores[:cashes].each do |c|
#      self.rebuild(:cash_controls, :cash, c.id)
#    end
#    self.rebuild(:income_books, :organism, @restores[:organism].id)
#    self.rebuild(:outcome_books, :organism, @restores[:organism].id)
#    self.rebuild(:od_books, :organism, @restores[:organism].id)
#    @restores[:books] = @restores[:income_books] + @restores[:outcome_books] +
#      @restores[:od_books]
#
#
#    Transfer.skip_callback(:create, :after, :create_lines)
#    self.rebuild(:transfers, :organism, @restores[:organism].id)
#
#    Period.skip_callback(:create, :after,:copy_accounts)
#    Period.skip_callback(:create, :after, :copy_natures)
#    self.rebuild(:periods, :organism, @restores[:organism].id)
#  rescue
#    Rails.logger.debug 'Erreur dans la création de l organisme ou dans les modèles attachés'
#  ensure
#    Organism.set_callback(:create, :after, :create_default)
#    Transfer.set_callback(:create, :after, :create_lines)
#    Period.set_callback(:create, :after,:copy_accounts)
#    Period.set_callback(:create, :after, :copy_natures)
#  end
#
#  def rebuild_period_and_children(period)
#    # Les natures qui appartiennent à une période mais qui ont un lien avec un account
#    @restores[:natures]=[]
#    @datas[:natures].each do |n|
#
#      new_attributes = n.attributes
#      new_attributes.delete 'id'
#      new_attributes[:period_id]=period.id
#      # si la nature est rattachée à un compte
#      # cherche l'index, ce qui suppose que les natures ont été créées
#      # dans le même ordre (a priori pas de pb mais peu fiable)
#      # TODO trouver une solution passant par une table de correspondance
#      if n.account_id
#        account_index = @datas[:accounts].index {|account| account.id == n.account_id}
#        new_attributes[:account_id]=@datas[:accounts][account_index].id if account_index
#      end
#      @restores[:natures] << Nature.create!(new_attributes)
#    end
#
#    @restores[:lines]= []
#    @datas[:lines].each do |l|
#      restore_line(l)
#    end
#
#    # Les lignes d'un extrait bancaire
#    @restores[:bank_extract_lines]=[]
#    @datas[:bank_extract_lines].each do |bel|
#      new_attributes=bel.attributes
#      new_attributes.delete 'id'
#      new_attributes[:bank_extract_id]=substitute(bel,:bank_extracts) if bel.bank_extract_id
#      new_attributes[:check_deposit_id]=substitute(bel,:check_deposits) if bel.check_deposit_id
#      new_attributes[:line_id]=substitute(bel,:lines) if bel.line_id
#      @restores[:bank_extract_lines] << BankExtractLine.create!(new_attributes)
#    end
#  end
#
#
#  # restore_line part d'une ligne et réadapte tous les id des champs belongs_to pour
#  # correspondre avec les nouvelles tables qui ont été créées précédemment
#  def restore_line(l)
#    new_attributes = l.attributes
#    new_attributes.delete 'id'
#    new_attributes[:book_id]=substitute_book(l) unless l.book_id.nil?
#    new_attributes[:destination_id]=substitute(l,:destinations) unless l.destination_id.nil?
#    new_attributes[:nature_id]=substitute(l,:natures) unless l.nature_id.nil?
#    new_attributes[:bank_account_id]=substitute(l,:bank_accounts) unless l.bank_account_id.nil?
#    new_attributes[:bank_extract_id]=substitute(l,:bank_extracts) unless l.bank_extract_id.nil?
#    new_attributes[:cash_id]=substitute(l,:cashes) unless l.cash_id.nil?
#    new_attributes[:check_deposit_id]=substitute(l,:check_deposits) unless l.check_deposit_id.nil?
#    new_attributes[:owner_id]=substitute_owner(l) unless l.owner_id.nil?
#    new_line=Line.new(new_attributes)
#    if  new_line.valid?
#      @restores[:lines] << Line.create!(new_attributes)
#    else
#      logger.debug new_line.errors.all
#    end
#
#  end
#
#
#  # lit le book_id de la ligne et y subsitue le nouvel book_id correspondant
#  # se fait à partir du titre qui doit être unique
#  def substitute_book(l)
#    title = @datas[:books].select {|b| b.id == l.book_id }.first[:title]
#    @restores[:books].select {|b| b.title == title}.first.id
#  end
#
#
#  # lit le owner_id et le owner_type
#  # actuellement, il ne peut s'agit que de 'Transfer'
#  # et cherche le transfer correspondant dans la reconstruction
#  def substitute_owner
#    transfer = @datas[:transfers].select {|t| t.id == l.owner_id }.first
#    transfer.delete :id
#    @restores[:transfers].select {|t| t.date == transfer.date && t.narration == transfer.narration && t.amount == transfer.amount}.first.id
#  end
#
#
#  # remplace les id des dépendances par un id issu de la reconstruction
#  # ainsi l'ancien nature_id de chaque line doit être remplacé par le nouvel
#  # par exemple subsitute(line, :natures)
#  # substitute suppose que les natures (toujours par exemple) ont été créées dans
#  # l'ordre de leurs id et qu'on peut donc mapper les anciennes natures et les nouvelles
#  # sur la base de leur rang.
#  # Un traitement spécial doit être fait pour IncomeBook et OutcomeBook
#  # car ils ne dépendent pas du modèle
#  # correspondant mais descendent de Book
#  def substitute(inst, sym_model)
#    logger.debug "Dans substitute #{sym_model.to_s}"
#    #    sym_model = :books if sym_model ==
#    sym_model_id = sym_model.to_s.singularize + '_id' # devient :nature_id
#    # recherche dans @datas[:natures] donc les données originales
#    # le rang de la nature originale
#    bi = @datas[sym_model].index {|r| r.id == inst.instance_eval(sym_model_id)}
#    logger.debug "index : #{bi}"
#    raise 'NoncoherentDatas' if bi.nil?
#    # et retourne comme valeur l'id correspondant à la nature qui a été restaurée
#    # @restores[:natures][bi].id
#    @restores[sym_model][bi].id
#  end
#
#
#  # attribute est un symbole qui renvoie à ce qu'on cherche à reconstituer
#  # parent est un autre symbole indiquant le parent
#  # rebuild remplit le restores[:attribute] qui est un Array,
#  # rebuild est utile pour construire les dépendances du type has_many - belongs_to
#  # pour les dépendances directes d'un parent
#  # Exemple : self.rebuild(:destinations, :organism, @restores[:organism].id)
#  def rebuild(attribute, parent, parent_id)
#    @restores[attribute]=[]
#    return unless @datas[attribute]
#    @datas[attribute].each do |a|
#      aa = a.attributes
#      aa.delete 'id' # id et type ne peuvent être mass attributed
#      aa.delete 'type'
#      aa[parent.to_s  + '_id'] = parent_id
#      @restores[attribute] << attribute.to_s.capitalize.singularize.camelize.constantize.create!(aa)
#    end
#    Rails.logger.info "reconstitution de #{@restores[attribute].size} #{attribute.to_s}"
#
#  end

end
