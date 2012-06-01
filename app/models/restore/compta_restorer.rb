# coding: utf-8

class RestoreError < StandardError; end


# Le module Restore a pour objet de restaurer une compta
# il se compose de trois classe RestoredCompta, RestoredModel et RestoredRecords.
module Restore



  # ComptaRestorer est une class qui permet de reconstruire une compta à partir d'un
  # fichier. On crée la classe en lui passant l'ensemble des valeurs, 
  # a priori lues à partir d'un fichier et parsée dans le controller
  # puis on reconstruit l'ensemble des valeurs dans la data base en
  # appelant rebuild_all_records
  # qui appelle successivement create_organism, create_direct_children
  # create sub_children et en dernier create_habtml 
  #
  # ComptaRestorer répond aussi à quelques méthodes :
  #
  # datas -> renvoie l'ensemble des données d'origine
  # restores -> est un hash qui contient des RestoredModel
  #  restores(:symbol) permet ainsi d'obtenir le RestoredModel correspondant
  #  par exemple restores(:destinations) renvoie le RestoredModel construit à partir
  #  des destinations
  # datas_for(sym_model) -> est équivalent à datas[:sym_model]
  # ask_id_for('destination', 12) renvoie le nouvel id correspondant à cette destination
  # reconstruite

  class ComptaRestorer

    

    attr_reader :restores, :errors, :datas
      
    def initialize(archive_file_datas)
      @errors = {}
      @restores = {}
      @datas = archive_file_datas
    end

  
    # rebuild_all_records appelle les quatre méthodes accessoires
    # successivement
    def compta_restore
      Organism.transaction do
        create_organism
        create_direct_children
        create_sub_children
        create_habtm
      end

    end

    # TODO gérer le cas de la demande pour un check_deposit_bank_extract_line alors que
    # la table est bank_extract_line

    # ask_id_for('transfer', 12) doit renvoyer le nouvel id correspondant à la recréation
    # de ce tansfer dans la compta
    def ask_id_for(model, old_id)
      Rails.logger.debug "ComptaRestorer #ask_id_for Modèle : #{model} - id demandée #{old_id} "
      required_model = model
      if model != 'book'
        model =  model.pluralize unless model == 'organism'
        sym_model = model.to_sym
        raise RestoreError, "Aucun enregistrement du type #{required_model.camelize}" unless @restores[sym_model]
        new_id = @restores[sym_model].new_id(old_id)
      else
        new_id = @restores[:income_books].new_id(old_id) || @restores[:outcome_books].new_id(old_id) ||  @restores[:od_books].new_id(old_id)
      end
      raise RestoreError, "Impossible de trouver un enregistrement du type #{required_model.camelize} avec comme id #{old_id}" if new_id.nil?
      Rails.logger.debug "ComptaRestorer #ask_id_for Modèle : #{model} - id demandée #{old_id} - réponse #{new_id} "
      new_id
    end


    def datas_for(sym_model)
      @datas[sym_model] 
    end

    protected

    def create_organism
      @restores[:organism] =  Restore::ModelRestorer.new(self, :organism)
      @restores[:organism].restore_record
    end

    # create_direct_children recréé les enregistrements qui sont
    # des enfants directs de organism.
    # Des skip_callback sont mis en place pour éviter les after_create
    # ensure s'assure qu'en tout état de cause les callbasks sont
    # réactivées à la fin de la méthode
    def create_direct_children
    
      [:destinations, :bank_accounts, :cashes, :income_books, 
        :outcome_books, :od_books, :transfers, :periods].each do |m|
        create_restore_model(m) 
      end
      
    ensure
      
    end


    # create sub_children est similaire à create_direct_children
    # mais appelle create_restore_model pour les modèles qui sont des enfants
    def create_sub_children
      create_restore_model(:bank_extracts) 
      
      create_restore_model(:cash_controls)
      create_restore_model(:accounts)
      create_restore_model(:natures)
      
     # les derniers car ils dépendent de bank_extract mais aussi de lines
      create_restore_model(:bank_extract_lines) 
      # en dernier car il dépend de check_deposit_bank_extract_lines
      create_restore_model(:check_deposits)
      create_restore_model(:lines)
   
    end

    # méthode pour reconstruire les liaisons habtm
    # existant entre bank_extract_lines et lines
    #
    # La table habtm est sauvegardée sous la forme d'un array de hash
    # constitué de bank_extract_line_id et line_id
    #
    # Il faut donc pour chaque hash chercher la bel correspondante
    # et lui ajouter la line correspondante
    #
    # La valeur de retour true or false indique s'il y a eu un problème
    #
    def create_habtm
      if @datas[:bank_extract_lines_lines]
        hr = Restore::HabtmRestorer.new(self, :bank_extract_line, :line)
        hr.restore_records(@datas[:bank_extract_lines_lines])
      else
        true # Pas de pb si pas de habtm
      end
    end


    # crée un nouveau restore_model sur la base du symbole entré
    # par exemple create_restore_model[:destinations]
    def create_restore_model(sym_model)
      if @datas[sym_model]
        @restores[sym_model] = Restore::ModelRestorer.new(self, sym_model)
        @restores[sym_model].restore_records
      end
    end


  
  end

end
