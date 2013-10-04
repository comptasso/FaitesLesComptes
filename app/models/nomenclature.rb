# coding: utf-8



# Nomenclature est une classe intermédiaire entre Organism et Folio
# Les folios définissent les données permettant de construire un document 
# comme l'actif, passif, compte de résultats et bénévolat (et peut être d'autres
# plus tard).
# 
# Mais les folios ne sont pas totalement indépendant les uns des autres
# Par exemple actif et passif sont étroitement reliés. 
# 
# C'est Nomenclature qui, par ses méthodes check_validity, permet de vérifier
# la cohérence des folios. 
# 
# # Il ne faut pas confondre avec Compta::Nomenclature qui est un objet beaucoup
# plus concret puisqu'il est associé à un exercice (period) et que Compta::Nomenclature
# peut donc faire des contrôles sur la validité des éditions qui seront produites.
#
# TODO  : Compta::Nomenclature est probablement devenu superflu 
# Voir à rapatrier ici ses fonctionnalités# 
# 
# Les validations ici ne concernent donc que la présence de l'organisme et des trois documents
# indispensables : actif, passif et résultat.
#
# # Nomenclature peut alors facilement créer une Compta::Nomenclature en lui
# fournissant l'exercice recherché et lui même
#
class Nomenclature < ActiveRecord::Base 

  
  belongs_to :organism
  has_many :folios, dependent: :destroy
  has_many :rubriks, through: :folios

  validates :organism_id, :presence=>true
  
  
  # TODO mettre dans une logique de checkup mais pas de validité
  # validate :check_validity
  # TODO c'est ici qu'il faut tester que actif passif et resultat sont bien présents
  # on doit aussi avoir des tests sur les comptes 6-7 8 et de bilan
  # laissant à Compta::Nomenclature juste le soin de vérifier sa bonne adapatation à la 
  # période.
  
  def actif
    folios.where('name = ?', :actif).first rescue nil
  end
  
  def passif
    folios.where('name = ?', :passif).first rescue nil
  end
  
  def resultat
    folios.where('name = ?', :resultat).first rescue nil
  end
  
  def benevolat
    folios.where('name = ?', :benevolat).first rescue nil
  end
  
  # permet de lire un fichier yml représentant la nomenclature utilisée pour
  # la présentation des comptes en différentes rubriques.
  # La méthode lit le fichier puis crée les rubriks correspondantes.
  def read_and_fill_folios(filename)
    yml = YAML::load_file(filename)
    
    transaction do
      yml.each do |k,v|
        f = folios.create(:name=>k, :title=>v[:title], sens:v[:sens])
        f.fill_rubriks_with_position(v[:rubriks])
      end
    end
  end
  
  
  # TODO à supprimer définitivement ainsi que la classe Compta::Nomenclature
  # crée une instance de Compta::Nomenclature pour l'exercice demandé
#  def compta_nomenclature(period)
#    Compta::Nomenclature.new(period, self)
#  end
  
  def sheet(period, folio)
    Compta::Sheet.new(period, folio) 
  end

  # méthode de présentation des erreurs
  #
  # TODO : on devrait mettre cette méthode dans un helper de présentation
  #
  # utilisée pour former le flash dans le controller AdminNomenclatures
  # mais également le messages qui est crée par le
  # AccountObserver lorsque la création d'un compte engendre une anomalie avec la nomenclature .
  def collect_errors
    al = ''
    unless valid?
      al = 'La nomenclature utilisée comprend des incohérences avec le plan de comptes. Les documents produits risquent d\'être faux.</br> '
      al += 'Liste des erreurs relevées : <ul>'
      errors.full_messages.each do |m|
        al += "<li>#{m}</li>"
      end
      al += '</ul>'

    end
    al.html_safe
  end

    

  # vérifie la validité de la nomenclature, laquelle repose sur l'existence 
  # de folios actif, passif et resultat.
  # 
  # Par ailleurs, chacun des folios doit être lui même valide
  def check_coherent
    errors.add(:actif, 'Actif est un folio obligatoire') unless actif
    errors.add(:passif, 'Passif est un folio obligatoire') unless passif
    errors.add(:resultat, 'Resultat est un folio obligatoire') unless resultat
    
    
    bilan_balanced? # tous les comptes C doivent avoir un compte D correspondant
    resultat_67?
    benevolat_8?
    bilan_no_doublon?
    
    # TODO reprendre les validations des folios eux mêmes
    folios.each do |f|
      errors.add(:folio, "Le folio #{f.name} indique une incohérence : #{f.errors.full_messages}") unless f.coherent?
    end
    # et reprendre la problématique des doublons dans un bilan (actif et passif)
  end
  
  # indique si une nomenclature est cohérente et donc utilisable pour produire des
  # états comptables
  def coherent?
    check_coherent
    errors.any? ? false : true
  end
  
      # sert à vérifier que si on compte C est pris, on trouve également un compte D
      # et vice_versa.
      # Ajoute une erreur à :bilan si c'est le cas avec comme message la liste des comptes
      # qui n'ont pas de correspondant
      def bilan_balanced?
      
        array_numbers = actif.rough_numbers + passif.rough_numbers
      
        # maintenant on crée une liste des comptes D et une liste des comptes C
        numbers_d = array_numbers.map {|n| $1 if n =~ /^(\d*)D$/}.compact.sort
        numbers_c = array_numbers.map {|n| $1 if n =~ /^(\d*)C$/}.compact.sort
    
        if numbers_d == numbers_c
          return true
        else
          d_no_c = numbers_d.reject {|n| n.in? numbers_c}
          c_no_d = numbers_c.reject {|n| n.in? numbers_d}
        
          self.errors[:bilan] << " : comptes D sans comptes C correspondant (#{d_no_c.join(', ')})" unless d_no_c.empty?
          self.errors[:bilan] << " : comptes C sans comptes D correspondant (#{c_no_d.join(', ')})" unless c_no_d.empty?
        
          return false
        end
      end
      
      def bilan_no_doublon?
        array_numbers = actif.rough_numbers + passif.rough_numbers
        errors.add(:bilan, 'Un numéro apparait deux fois dans la construction du bilan') unless array_numbers.uniq.size == rough_numbers
      end
      
      
      
      # le folio résultat ne peut avoir que des comptes 6 ou 7
      def resultat_67?
        list = rough_accounts_reject(resultat.rough_numbers, 6,7)
        errors.add(:resultat, "comprend un compte étranger aux classes 6 et 7 (#{list.join(', ')})") unless list.empty?
      end
      
      
      
      # le folio benevolat ne peut avoir que des comptes 8
      # le folio résultat ne peut avoir que des comptes 6 ou 7
      def benevolat_8?
        list = rough_accounts_reject(benevolat.rough_numbers, 8)
        errors.add(:benevolat, "comprend une rubrique étrangere à la classe 8 (#{list.join(', ')})") unless list.empty?
      end
  
      def rough_accounts_reject(array_numbers, *args)
        args.each do |a|
          array_numbers.reject! {|n| n =~ /^[-!]?#{a}\d*/}
        end
        array_numbers
      end


end