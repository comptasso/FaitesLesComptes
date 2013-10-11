# Un folio décrit le mode de construction d'un document comptable, par exemple
# actif ou passif ou résultat
# 
# Un folio a 
# - un name : actif, passif, résultat, bénévolat sont actuellement les seuls
# envisagés.
# - un title comme Bilan Actif
# - un sens :actif ou :passif qui déterminera la façon dont on veut produire
# le document avec 4 colonnes (brut,amortissement, net, previous_net) ou 
# 2 colonnes (net, previous_net)
# - des rubriks : ce sont ces rubriks qui décrivent la façon dont les comptes 
# sont retenus pour former chacune des rubriques
# 
# A noter que le folio est indépendant de l'exercice. Il n'est donc pas possible
# à ce niveau de vérifier que le plan comptable utilisé et le folio sont cohérents.
# 
# Seules peuvent être réalisées des contrôle sur le fait qu'un compte n'est pas 
# pris deux fois
#
class Folio < ActiveRecord::Base
  attr_accessible :name, :title, :sens
  attr_reader :counter
  has_many :rubriks, dependent: :destroy
  belongs_to :nomenclature
  
  # TODO mettre une validation pour name 
  
  validates :sens, :inclusion=>{:in=>[:actif, :passif]}
  # 
  # méthode créant les rubriks de façon récursive à partir d'un hash
  # la clé :numéros n'est remplie que si la valeur n'est pas elle même un Hash
  # 
  # méthode appelée par read_and_fill_rubriks
  
  def fill_rubriks_with_position(hash)
    @counter = 0
    fill_rubriks(hash, nil)
  end
  
  
  # TODO pour être valide un folio ne peut avoir deux fois le même numéro de compte
  # TODO mettre les validations sur les champs obligatoires
  # 
  
  # TODO faire les specs de ce modèle
  
  
  
  # un folio doit être capable de retounrer les rubriques dans un ordre précis
  # les premières branches suivies des branchettes suivies des feuilles
  
  # renvoie la rubrique racine de ce folio
  def root
    rubriks.root
  end
  
  # Permet d'extraire toutes les instructions de liste de comptes de la nomenclature
  # la logique récursive permet de faire des nomenclatures à plusieurs niveaux
  # sans imposer un nombre de niveaux précis.
  #
  # 
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
  
  def create_rubrik(name, parent_id)
    @counter += 1
    rubriks.create(:name=>name, :parent_id=>parent_id, :position=>counter)
  end
  
  
  def fill_rubriks(hash, parent_id = nil)
    hash.each do |k,v|
      r = create_rubrik(k, parent_id)
      if v.is_a? Hash
        fill_rubriks(v, r.id)
      else
        r.update_attribute(:numeros, v)
      end
    end
  end
  
  
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
