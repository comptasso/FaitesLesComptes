# coding: utf-8

class Archive < ActiveRecord::Base
  belongs_to :organism

  attr_reader  :datas, :restores

  # FIXME voir si psych permet de vérifier la validité du fichier
  def parse_file(archive)
    @datas = YAML.load(archive)
    #  rescue
    #    @errors << "Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"
  end

  # à partir d'un exercice, collect_data constitue un hash reprenant l'ensemble des données
  # de cet exercice
  def collect_datas
    @datas={}
    @datas[:comment]=self.comment
    @datas[:created_at]=self.created_at
    @datas[:organism]=self.organism
    @datas[:periods]=organism.periods.all
    @datas[:bank_accounts]=organism.bank_accounts.all
    @datas[:destinations]=organism.destinations.all
    @datas[:lines] =organism.lines.all
    @datas[:bank_extracts]=organism.bank_extracts.all
    @datas[:check_deposits]=organism.check_deposits.all
    @datas[:cashes]=organism.cashes.all
    @datas[:cash_controls]=organism.cash_controls.all
    @datas[:books]=organism.books.all
    @datas[:accounts]=organism.accounts.all
    @datas[:natures]=organism.natures.all
    @datas[:bank_extract_lines]=organism.bank_extract_lines.all
  end


  def list_errors
    self.errors.join('\n')
  end

  
  def organism_exists?
    Organism.where('title = ? ', self.organism.title).nil? ? false : true
  end

  def rebuild_organism
    @restores={}
    Organism.transaction do
      self.rebuild_organism_and_direct_children
    if @restores[:periods]
      @restores[:periods].each do |p|
        self.rebuild_period_and_children(p)
      end
    end
     end
  rescue ActiveRecord::RecordInvalid => invalid
    Rails.logger.warn 'Erreur dans la reconstitution des données'
  end



  # utilisée pour recharger un nouvel organism dans une compta
  # TODO faire tout ceci dans une transaction en cas de problème
  def rebuild_organism_and_direct_children
    Organism.skip_callback(:create, :after ,:create_default)
    a=@datas[:organism].attributes
    a.delete 'id'
    @restores[:organism]= Organism.create!(a)

    self.rebuild(:destinations, :organism, @restores[:organism].id)
    self.rebuild(:bank_accounts,:organism, @restores[:organism].id)
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
    Period.skip_callback(:create, :after,:copy_accounts)
    Period.skip_callback(:create, :after, :copy_natures)
    self.rebuild(:periods, :organism, @restores[:organism].id)
  rescue
    Rails.logger.debug 'Erreur dans la création de l organisme ou dans les modèles attachés'
  ensure
    Organism.set_callback(:create, :after,:create_default)
    Period.set_callback(:create, :after,:copy_accounts)
    Period.set_callback(:create, :after, :copy_natures)
  end

  def rebuild_period_and_children(period)
    # Les natures qui appartiennent à une période mais qui ont un lien avec un account

    @datas[:natures].each do |n|

      new_attributes=n.attributes
      new_attributes.delete 'id'
      new_attributes[:period_id]=period.id

      if n.account_id
        bi= @datas[:accounts].index {|r| r.id == n.account_id}

        new_attributes[:account_id]=@datas[:accounts][bi].id if bi
      end

      Nature.create!(new_attributes)
    end



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
      Line.create!(new_attributes)

    end

    # Les lignes d'un extrait bancaire

    @datas[:bank_extract_lines].each do |bel|
      new_attributes=bel.attributes
      new_attributes.delete 'id'
      new_attributes[:bank_extract_id]=substitute(bel,:bank_extracts) if bel.bank_extract_id
      new_attributes[:check_deposit_id]=substitute(bel,:check_deposits) if bel.check_deposit_id
      new_attributes[:line_id]=substitute(bel,:lines) if bel.line_id
      bel.create!(new_attributes)
    end
  end

  def substitute(inst, sym_model)
    sym_model_id=sym_model.to_s.singularize + '_id'
    bi=@datas[sym_model].index {|r| r.id == inst.instance_eval(sym_model_id)}
    raise 'NoncoherentDatas' if bi.nil?
    @datas[sym_model][bi].id
  end


  # attribute est un symbole qui renvoie à ce qu'on cherche à reconstituer
  # parent est un autre symbole indiquant le parent
  # rebuild remplit le restores[:attribute] qui est un Array,
  # rebuild est utile pour construire les dépendances du type has_many - belongs_to
  def rebuild(attribute, parent, parent_id)
    @restores[attribute]=[]
    return unless @datas[attribute]
    @datas[attribute].each do |a|
      aa=a.attributes
      aa.delete 'id' # id et type ne peuvent être mass attributed
      aa.delete 'type'
      aa[parent.to_s  + '_id']=parent_id
      @restores[attribute] << attribute.to_s.capitalize.singularize.camelize.constantize.create!(aa)
    end
    Rails.logger.info "reconstitution de #{@restores[attribute].size} #{attribute.to_s}"

  end

end
