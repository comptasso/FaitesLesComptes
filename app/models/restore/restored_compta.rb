# coding: utf-8

module Restore

  MODELS = %w(period bank_account destination line bank_extract check_deposit cash cash_control book account nature bank_extract_line income_book outcome_book transfer)


  # RestoredCompta est une class qui permet de reconstruire une compta à partir d'un
  # fichier. On crée la classe en lui passant le nom d'un fichier
  # puis on reconstruit l'ensemble des valeurs dans la data base en
  # appelant successivement create_organism, create_direct_children
  # create sub_children.

  # Tout cet enchainement devra être mis dans une transaction
  class RestoredCompta

    attr_reader :restores
    
    
    def initialize(archive_name)
      @archive_name = archive_name  
      @errors = {}
      @restores = {}
      parse_file
    end

    def basename
      File.basename(@archive_name)
    end

    def datas
      @datas ||= parse_file
    end

    def create_organism
      Organism.skip_callback(:create, :after ,:create_default)
      @restores[:organism] =  Restore::RestoredModel.new(self, :organism)
      @restores[:organism].restore_record
    ensure
      Organism.set_callback(:create, :after, :create_default) 
    end

    # renvoie l'id
    def organism_new_id
      raise 'le nouvel organism n a pas encore été créé' unless @restores[:organism]
      @restores[:organism].records.first.id
    end

    def create_child(sym_model) #, parent = nil, pid = nil)
      parent ||= :organism
      pid ||= organism_new_id
      @restores[sym_model] = restore_model(self, sym_model) #,parent, pid )
      @restores[sym_model].restore_records 
    end


    def datas_for(sym_model)
      @datas[sym_model]
    end
 

    # create_direct_children recréé les enregistrements qui sont
    # des enfants directs de organism.
    # Des skip_callback sont mis en place pour éviter les after_create
    # ensure s'assure qu'en tout état de cause les callbasks sont
    # réactivées à la fin de la méthode
    def create_direct_children
      Transfer.skip_callback(:create, :after, :create_lines)
      Period.skip_callback(:create, :after,:copy_accounts)
      Period.skip_callback(:create, :after, :copy_natures)
      [:destinations, :bank_accounts, :cashes, :income_books, 
        :outcome_books, :od_books, :transfers, :periods].each do |m|
        create_child(m) if @datas[m]
      end
      
     ensure
      Transfer.set_callback(:create, :after, :create_lines)
      Period.set_callback(:create, :after,:copy_accounts)
      Period.set_callback(:create, :after, :copy_natures)
    end


    # create sub_children est similaire à create_direct_children
    # mais appelle create_child pour les modèles qui sont des enfants
    def create_sub_children
      [:bank_extracts, :check_deposits, :cash_controls, :accounts].each { |m| create_child(m) if @datas[m] }
      create_child(:natures) if @datas[:natures]
      create_child(:lines) if @datas[:lines]
      # les derniers car ils dépendent de bank_extract mais aussi de lines
      create_child(:bank_extract_lines) if @datas[:bank_extract_lines]
    end

    

    # la particularité des natures c'est qu'ils ont un account_id et un period_id
#    def create_natures
#      unless @restores[:periods].empty?
#        @restores[:periods].records.each do |p|
#          @restores[:natures] = Restore::RestoreModel.new(:natures,:period_id, p.id)
#          @restores[:natures].restore_records(@datas[:natures] )
#        end
#      end
#    end

    # ask_for_id('transfer', 12) doit renvoyer le nouvel id correspondant à la recréation
    # de ce tansfer dans la compta
    def ask_id_for(model, old_id)
      if model != 'book'
        model =  model.pluralize unless model == 'organism'
        sym_model = model.to_sym
        return  @restores[sym_model].new_id(old_id)
      else
        return @restores[:income_books].new_id(old_id) || @restores[:outcome_books].new_id(old_id) ||  @restores[:od_books].new_id(old_id)
      end
    end

    protected


    # prend un modèle sous forme de symbole et le restaure
    def restore_model(sender, sym_model) #, parent = nil, pid = nil)
      Restore::RestoredModel.new(sender, sym_model) #, parent, pid)
    end


    
    # parse_file prend un fichier archive, charge les fichiers nécessaires
    # load et non require pour être certain de les recharger si nécessaire
    # et retourne les @datas
    def parse_file
      require 'yaml'
      load('organism.rb')
      MODELS.each do |model_name|
        load(model_name + '.rb')
      end
      File.open(@archive_name, 'r') do |f|
        @datas = YAML.load(f)
      end
    rescue  Psych::SyntaxError
      errors[:base] = "Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"
    end




  end

end
