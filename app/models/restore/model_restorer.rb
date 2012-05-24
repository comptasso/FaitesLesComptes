# coding: utf-8

module Restore


  # la classe RestoreModel sert à reconstruire un modèle donné à partir
  # des données d'une sauvegarde.
  # Elle est appelée par ComptaRestorer pour chacun des modèles utilisés
  # pour enregistrer une compta.
  # RestoreModel utilise alors la classe RestoreRecords pour constuire les
  # enregistrements proprements dits avec un mapping des anciennes id.
  class ModelRestorer

    attr_reader  :compta

    def initialize(sender, sym_model) #, parent = nil, parent_id = nil)
      @sym_model = sym_model # @model_name = sym_model.to_s.capitalize.singularize.camelize :model_name,
#      @parent_id = parent_id
#      @parent = parent
      @compta = sender
    end

    # Restore plusieures records à partir d'un tableau d'enregistrement
    #
    # Appelle la classe RestoreRecords pour construire un nouveau tableau
    # contenant l'ancien id et le nouveau record
    # les datas sont fournis par l'appel à la méthode correspondante
    def restore_records
      @r_records = Restore::RecordsRestorer.new(@compta)
      @r_records.restore_array(@compta.datas_for(@sym_model))
    end

    # Restore un record qui n'est pas dans un array
    # en l'occurence organism
    #
    # Pour les modèles qui ont plusieurs records, utiliser restore_records
    #
    def restore_record
      @r_records = Restore::RecordsRestorer.new(@compta)
      @r_records.restore(@compta.datas_for(@sym_model))
    end

    # records demande à restore records de lui donner juste le tableau des
    # nouveau records
    def records
      raise 'r_records est vide et les records ne peuvent etre restaures' unless @r_records
      @r_records.all_records 
    end

    def length
      records.length
    end

    # les id_records sont un tableau de hash consitué de l'anci
    def id_records
      raise 'r_records est vide et les records ne peuvent etre restaures' unless @r_records
      @r_records.id_records
    end

    # permet de savoir si un restored_model est vide
    def empty?
      return true unless @r_records
      @r_records.all_records.empty?
    end

    # retourne l'id correspondante à un nouvel enregistrement
    def new_id(old_id)
      # donc on cherche dans id_records un record qui a pour old_id comme :old_id
      h = id_records.select {|r| r[:old_id] == old_id}
      h.empty?  ? nil : h.first[:record].id
    end




  end



end