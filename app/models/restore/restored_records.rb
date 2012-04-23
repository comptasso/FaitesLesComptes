# coding: utf-8

# coding: utf-8

module Restore

  # cette classe génère les enregistrements restorés par un modèle donné
  # elle est constituée d'un tableau de hash,
  # chacun des hash ayant old_id, et le nouveau record créé

  # une fois créé :
  # - id_records donne tous le tableau associatif
  # :old_id=>XX, :record=>the_new_record
  # - all_records permet d'avoir un tableau de tous les records
  class RestoredRecords
    attr_reader :id_records
    
    def initialize
      @id_records = []
    end


    # restore un seul enregistrement
    # par exemple restore_data[@datas[:organism]
    # parent est un symbole au singulier
    def restore_data(data, parent = nil, parent_id = nil)
        dd = data.attributes
        new_dd = {:old_id=>data[:id] }
        dd.delete 'id' # id et type ne peuvent être mass attributed
        dd.delete 'type'
        dd[parent.to_s  + '_id'] = parent_id if parent
        new_dd[:record]  = data.class.name.constantize.create!(dd)
        @id_records << new_dd
     end

    # à partir d'un tableau de records, extrait le nom de la class
    # supprime l'id, créé un nnouveau record du même modèle
    # stocke l'ancien id et ce nouveau record dans @restore_records
    def restore_datas(datas, parent = nil, parent_id=nil)
       datas.each do |d|
        restore_data(d, parent, parent_id)
      end
      Rails.logger.info "reconstitution de #{datas.size} #{datas.first.class.name}"
    end

    # retourne juste les enregistrements
    def all_records
      @id_records.map {|rr| rr[:record]}
    end

  end

end
