# coding: utf-8

class Hash
  # retire tous les attributs id et xxx_id du hash pour
  # permettre une comparaison sur les autres champs
  def remove_ids
    delete('id')
    map {|k,v|  k }.grep(/_id$/).each  { |a| delete(a) }
  end
end


class Array
  # pour comparer la similitude de deux arrays de records
  def similar_to?(other)
    self.each_with_index {|r, i| return false unless r.similar_to? other[i] }
    true
  end
end
  

class  ActiveRecord::Base
   
  # permet de comparer deux destinations sur l'ensemble des champs en dehors
  # du champ organism_id, et des différents champs _id
  # utile pour vérifier que les modèles sont bien reconstruits avec toutes les
  # données identiques sauf évidemment les _id
  def similar_to?(other)
    attributes = self.attributes.remove_ids
    other_attributes = other.attributes.remove_ids
    attributes == other_attributes
  end


end
