require 'benchmark'

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
# sont retenus pour former chacune des rubrique
# un folio doit être capable de retourner les rubriques dans un ordre précis
# les premières branches suivies des branchettes suivies des feuilles
# 
# A noter que le folio est indépendant de l'exercice. Il n'est donc pas possible
# à ce niveau de vérifier que le plan comptable utilisé et le folio sont cohérents.
# 
# Seules peuvent être réalisées des contrôle sur le fait qu'un compte n'est pas 
# pris deux fois et sur le fait qu'un folio resultat n'utilise que des rubriques 
# commençant par des 6 et des 7
# 
# La méthode coherent? contrôle que les rubriques sont cohérentes : pas de doublon,
# que des comptes 6 et 8 pour un compte de résultat, que des comptes 8 pour un compte
# de bénévolat.
# 
# coherent? ne peut être dans les validations car la création des rubriques, enfants du folio
# ne peut être faite qu'une fois le folio créé (car les rubriques ont une logique 
# de acts_as_list, ce qui fait qu'il faut les créer réellement pour passer aux enfants. 
#  
#  TODO un contrôle pas de compte 8 sur le bilan.
#
class Folio < ActiveRecord::Base
  attr_accessible :name, :title, :sens
  attr_reader :counter
  has_many :rubriks, dependent: :destroy
  belongs_to :nomenclature
  belongs_to :sector
  
  # TODO mettre une validation pour name 
  
  validates :nomenclature_id, :name, :title, :presence=>true
  validates :sens, :inclusion=>{:in=>[:actif, :passif]}
  # test est rajouté pour faciliter les tests
  validates :name, :inclusion=>{:in=>[:actif, :passif, :resultat, :resultatASC, :resultatfonc, :benevolat, :test]}
 
  # 
  # méthode créant les rubriks de façon récursive à partir d'un hash
  # la clé :numéros n'est remplie que si la valeur n'est pas elle même un Hash
  # 
  def fill_rubriks_with_position(hash)
    @counter = 0
    fill_rubriks(hash, nil)
  end
  
  def coherent?
    no_doublon?
    only_67 if name == :resultat
    only_8 if name == :benevolat
    errors.empty? ? true : false
  end
  
  
  # TODO pour être valide un folio ne peut avoir deux fois le même numéro de compte, 
  # la méthode no_doublon et coherent? existe mais n'est pas encore incluse dans les validations
  # 
  # TODO mettre les validations sur les champs obligatoires
  # 
  
  # TODO faire les specs de ce modèle, il faut par exemple vérifier que bénévolat ne 
  # prend que des instructions commençant par 8 et resultat que 6 ou 7
  # 
  
  
  
  
  
  # renvoie la rubrique racine de ce folio
  def root
    rubriks.root
  end
  
  # TODO à supprimer après mise au point
  def bench_lines(period)
    Benchmark.bm do |bm|
      bm.report {root.fetch_lines(period)}
    end
  end
  
  # Permet d'extraire toutes les instructions de liste de comptes de la nomenclature
  # la logique récursive permet de faire des nomenclatures à plusieurs niveaux
  # sans imposer un nombre de niveaux précis.
  #
  # Le résultat est un array d'instructions comme
  #  ["201 -2801", "203 -2803", "206 207 -2807 -2906 -2907", "208 -2808 -2809", ..., "53", "486", "481"] 
  #
  # 
  def all_instructions
    root.all_instructions
  end
  
  # rencoie la liste brute des informations de comptes repris dans la partie doc
  # rough_instructions(:benevolat) renvoie par exemple %w(87 !870 870 86 !864 864)
  def rough_instructions
    all_instructions.join(' ').split
  end
  
  def all_numbers(period)
    all_instructions.map {|accounts| Compta::RubrikParser.new(period, :actif, accounts).list_numbers}.flatten
  end
  
  def all_numbers_with_option(period)
    all_instructions.map {|accounts| Compta::RubrikParser.new(period, :actif, accounts).list}.flatten
  end
  
  # surcharge de title pour gérer les CE qui affichent en subtitle leur secteur
  # dans les pdf. (Ceci pour des questions de mise en page)
  def pdf_title
    return 'Compte de Résultats' if name == 'resultatASC' || name == 'resultatfonc'
    read_attribute(:title)
  end
  
  # permet d afficher en subtitle le secteur pour les organisations sectorisées
  # (comité d'entreprise)
  def subtitle
    case name
    when 'resultatASC' then 'Activités sociales et culturelles'
    when 'resultatfonc' then 'Fonctionnement'
    else ''
    end
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
        r.numeros = v
        r.is_leaf = true
        r.save
        
      end
    end
  end
  
  # vérifie qu'il n'y a pas d'instruction en double.
  # Attention, cela ne permet pas de s'exonérer d'un contrôle des doublons sur 
  # les comptes réels de l'exercice.
  def no_doublon?
    errors.add(:rubriks, 'Un numéro apparait deux fois dans le folio') unless rough_instructions.uniq.size == rough_instructions.size
  end
    
  # vérifie que rough_instructions ne contient que des instructions commençant par 6 ou 7
  def only_67
    no67 = rough_instructions.select {|instr| instr =~ /^[^67]\d*/}
    errors.add(:rubriks, "Un compte de résultats ne peut prendre que des comptes 6 ou 7 , trouvé #{no67.join(', ')}") unless no67.empty?
  end
    
  def only_8
    no8 = rough_instructions.select {|instr| instr =~ /^[^8]\d*/}
    errors.add(:rubriks, "Un compte de résultats ne peut prendre que des comptes 6 ou 7 , trouvé #{no8.join(', ')}") unless no8.empty?
  end
      


end
