# coding: utf-8


# on réouvre le modèle ActiveRecord::Base pour créer une méthode générale
# restore
class ActiveRecord::Base

  # restore permet de reconstruire un enregistrement de la compta
  # l'argument new_attributes doit avoir été préparé, notamment
  # il ne peut avoir id ni type, et les aaaa_id doivent avoir été fournis
  # correctement par compta_restorer
  #
  # Les modèles qui nécessitent un skip_callback doivent surcharger cette méthode
  # Renvoie le modèle nouvellement créé
  def self.restore(new_attributes)
       restored = self.new(new_attributes)
       Rails.logger.info "création de #{restored.class.name} with #{restored.attributes}"
       Rails.logger.warn "Erreur : #{restored.errors.inspect}" unless restored.valid?
       puts "Erreur : #{restored.errors.inspect}" unless restored.valid?
       restored.save!
       restored
  end
end


module Restore

  # cette classe génère les enregistrements restorés par un modèle donné
  # elle est constituée d'un tableau de hash,
  # chacun des hash ayant :old_id, et le nouveau :record créé

  # une fois créé :
  # - id_records donne tous le tableau associatif
  # :old_id=>XX, :record=>the_new_record
  # - all_records permet d'avoir un tableau de tous les records
  class RecordsRestorer
    attr_reader :id_records, :compta
    
    def initialize(compta)
      @compta = compta
      @id_records = []
    end


    # retourne juste les enregistrements
    def all_records
      @id_records.map {|rr| rr[:record]}
    end


    # Prend un array de records et les reconstruit un par un
    # retourne le nombre de records reconstruits
    def restore_array(datas)
      nb_restoration = @id_records.size
      datas.each {|d| restore(d)}
      @id_records.size - nb_restoration
    end


    # Restore est une fonction générale qui prend un record, l'analyse,
    # lui substitue les id qui vont bien
    #
    # Puis la méthode appelle Model.restore (définie plus haut par une extension
    # de ActiveRecord::Base (éventuellement surchargée)
    #
    def restore(data)
      new_dd = {:old_id=>data[:id] }
      new_attributes = data.attributes
      child_id(data).each do |a_id|
        new_attributes[a_id] = find_id_for(data, a_id)
      end

      # efface les attributs id et type de data car ils ne peuvent être mass attributed
      new_attributes.delete 'id'
      new_attributes.delete 'type'

      if data.class == Organism
        new_dd[:record] = Organism.restore(new_attributes)
        Rails.logger.debug "#{new_dd[:record].errors.inspect}" unless new_dd[:record].valid?
      else
        new_dd[:record] = data.class.name.constantize.restore(new_attributes)
#        new_dd[:record] = data.class.name.constantize.new(new_attributes)
#        Rails.logger.debug "#{new_dd[:record].errors.inspect}"   unless new_dd[:record].valid?
#        new_dd[:record].save!
      end
      @id_records << new_dd
      Rails.logger.debug "#{new_dd.inspect} "
    end


    # Deux cas de figure, soit il y a un champ polymorphique
    # soit pas. Le premier cas est traité par une vérification de la présence
    # du _type
    def find_id_for(data, a_id)
      # cas le plus facile, id est nil et on retourne nil
      return nil if data.attributes[a_id] == nil
      # cas général
      model = a_id[/(.*)(_id$)/,1] # le modèle est obtenu en retirant _id par exemple book à partir de book_id
      # cas polymorphic , alors le modèle est obtenu en lisant le type
      # par exemple owner_id ne renvoie pas à owner mais a Transfer (que l'on obtient en regardant owner_type)
      model = model_polymorphic(data, a_id)  if polymorphic?(data, a_id)
      # maintenant on demande à compta de retourner le nouvel id correspondant
      # à ce modèle et à cet id
      # par exemple ask_id_for('Nature', 27) si la ligne aveait un nature_id de 27
     # Rails.logger.debug "Modèle : #{data.inspect} - a_id : #{a_id}  "
      rid = @compta.ask_id_for(model, data.attributes[a_id])
      Rails.logger.debug "reponse : #{rid} "
      rid
    end

    protected

    # on détecte polymorphique en regardant si il y a un _type qui va avec le _id
    # par exemple si owner_id il y aussi owner_type
    def polymorphic?(data, a_id)
      racine = a_id[/(.*)(_id$)/,1]
      data.attributes.map {|k,v| k }.include?(racine + '_type')
    end

   

    # renvoie un tableau de tous les champs de data qui se terminent en _id
    def child_id(data)
      data.attributes.map {|k,v|  k }.grep(/_id$/)
    end

    # on détecte polymorphique en regardant si il y a un _type qui va avec le _id
    # par exemple si owner_id il y aussi owner_type
    def polymorphic?(data, a_id)
      racine = a_id[/(.*)(_id$)/,1]
      data.attributes.map {|k,v| k }.include?(racine + '_type')
    end

    # par exemple owner_id racine = owner, data.attribtues[:owner_type] = "Transfer"
    def model_polymorphic(data, a_id)
      racine = a_id[/(.*)(_id$)/,1]
      data.attributes[racine + '_type'].underscore
    end




  end

end
