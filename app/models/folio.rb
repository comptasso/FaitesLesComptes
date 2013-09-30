class Folio < ActiveRecord::Base
  attr_accessible :name, :title, :sens
  has_many :rubriks
  
  
  # TODO pour être valide un folio ne peut avoir deux fois le même numéro de compte
  
  # méthode créant les rubriks de façon récursive à partir d'un hash
  # la clé :numéros n'est remplie que si la valeur n'est pas elle même un Hash
  # 
  # méthode appelée par read_and_fill_rubriks
  def fill_rubriks(hash, parent_id = nil)
    hash.each do |k,v|
      r = self.rubriks.create(:name=>k, :parent_id=>parent_id)
      if v.is_a? Hash
        fill_rubriks(v, r.id)
      else
        r.update_attribute(:numeros, v)
      end
    end
  end
  
  
  
  # un folio doit être capable de retounrer les rubriques dans un ordre précis
  # les premières branches suivies des branchettes suivies des feuilles
  
  # renvoie la rubrique racine de ce folio
  def root
    rubriks.where('parent_id IS NULL').first
  end
  
  # Permet d'extraire toutes les instructions de liste de comptes de la nomenclature
  # la logique récursive permet de faire des nomenclatures à plusieurs niveaux
  # sans imposer un nombre de niveaux précis
  def all_numbers
    return [root.numeros] if root.leaf? # cas quasi impensable où il n'y aurait qu'une rubrique
    values = []
    collect_numeros(values, root)
    values.flatten
  end
  
  # rencoie la liste brute des informations de comptes repris dans la partie doc
  # rough_numbers(:benevolat) renvoie par exemple %w(87 !870 870 86 !864 864)
  def rough_numbers
    all_numbers.join(' ').split
  end
  
  # méthode permettant de savoir si le folio est cohérent
  def coherent?
    no_doublon?
    errors.any? ? false : true
  end
  
    
  
  
  protected
  
    def no_doublon?
      errors.add(:rubriks, 'Un numéro apparait deux fois dans le folio') unless rough_numbers.uniq.size == rough_numbers
    end
      
  def collect_numeros(values, rubriks)
    rubriks.children.each do |r|
      if r.leaf?
        values << r.numeros
      else 
        collect_numeros(values, r) 
      end
    end
  end

end
