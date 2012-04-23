# coding: utf-8

module Restore


  # la classe RestoreModel sert à reconstruire un modèle donné à partir
  # des données d'une sauvegarde.
  # Elle est appelée par RestoreCompta pour chacun des modèles utilisés
  # pour enregistrer une compta.
  # RestoreModel utilise alors la classe RestoreRecords pour constuire les
  # enregistrements proprements dits avec un mapping des anciennes id.
  class RestoredModel

    attr_reader  :compta

    def initialize(sender, sym_model, parent = nil, parent_id = nil)
      @sym_model = sym_model # @model_name = sym_model.to_s.capitalize.singularize.camelize :model_name,
      @parent_id = parent_id
      @parent = parent
      @compta = sender
    end

    # à partir d'un tableau d'enregistrement
    # appelle la classe RestoreRecords pour construire un nouveau tableau
    # contenant l'ancien id et le nouveau record
    # les datas sont fournis par l'appel à la méthode correspondante
    def restore_records
      @r_records = Restore::RestoredRecords.new
      @r_records.restore_datas(@compta.datas_for(@sym_model), @parent, @parent_id)
    end

    # utilisé pour la restauration de records qui ne sont pas dans un array
    # en l'occurence organism
    def restore_record
      @r_records = Restore::RestoredRecords.new
      @r_records.restore_data(@compta.datas_for(@sym_model))
    end

    # records demande à restore records de lui donner juste le tableau des
    # nouveau records
    def records
      raise 'r_records est vide et les records ne peuvent etre restaures' unless @r_records
      @r_records.all_records 
    end

    def id_records
      raise 'r_records est vide et les records ne peuvent etre restaures' unless @r_records
      @r_records.id_records
    end

    # permet de savoir si un restored_model est vide
    def empty?
      return true unless @r_records
      @r_records.all_records.empty?
    end




  end



end