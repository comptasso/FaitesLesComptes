# coding: utf-8



# Nomenclature enregistre dans ses 4 champs texte les informations permettant
# de construire les documents de bilan, Actif et Passif, le compte de Résultat
# ainsi que le compte de Benevolat.
#
# Un cinquième champ organism_id fait le lien avec l'organisme.
# 
# Une nomenclature est donc attachée à un organisme
# Il ne faut pas confondre avec Compta::Nomenclature qui est un objet beaucoup
# plus concret puisqu'il est associé à un exercice (period) et que Compta::Nomenclature
# peut donc faire des contrôles sur la validité des éditions qui seront produites.
#
# Les validations ici ne concernent donc que la présence de l'organisme et des trois documents
# indispensables : actif, passif et résultat.
#
# Une dernière validation est réalisée par check_validity, qui en fait délègue la
# validation à Compta::Nomenclature.
#
#
# Nomenclature peut alors facilement créer une Compta::Nomenclature en lui
# fournissant l'ensemble des instructions sous forme d'un hash
#
class Nomenclature < ActiveRecord::Base 

  
  belongs_to :organism
  has_many :folios
  has_many :rubriks, through: :folios

  attr_accessible :actif, :passif, :resultat, :benevolat

  # TODO une nomenclature est valide si elle a 3 folios avec comme nom actif, passif 
  validates :organism_id, :presence=>true
  # TODO mettre dans une logique de checkup mais pas de validité
  # validate :check_validity
  
  def actif
    folios.where('name = ?', :actif).first
  end
  
  def passif
    folios.where('name = ?', :passif).first
  end
  
  def resultat
    folios.where('name = ?', :resulat).first
  end
  
  def benevolat
    folios.where('name = ?', :benevolat).first
  end
  
  

  def instructions
    {:actif=>actif, :passif=>passif, :resultat=>resultat, :benevolat=>benevolat}
  end
  
  
  # permet de lire un fichier yml représentant la nomenclature utilisée pour
  # la présentation des comptes en différentes rubriques.
  # La méthode lit le fichier puis crée les rubriks correspondantes.
  def read_and_fill_folios(filename)
    yml = YAML::load_file(filename)
    
    Nomenclature.transaction do
      yml.each do |k,v|
        f = folios.create(:name=>k, :title=>v[:title], sens:v[:sens])
        f.fill_rubriks(v[:rubriks])
      end
    end
  end
  
  
  
  # crée une instance de Compta::Nomenclature pour l'exercice demandé
  def compta_nomenclature(period)
    Compta::Nomenclature.new(period, instructions)
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

  protected
  
  

  # vérifie la validité de la nomenclature pour l'ensemble des exercices
  # et recopie dans les erreurs de l'instance, les erreurs éventuelles trouvées
  # dans les Compta::Nomenclature
  def check_validity
    if organism # car sinon le test de validité sans organism crée une erreur ici
      organism.periods.each do |p|
        cn = Compta::Nomenclature.new(p, instructions)
        unless cn.valid?
          cn.errors.messages.each {|k, m| self.errors[k] << "#{m.join('; ')} pour #{p.exercice}"}
        end
      end
    end

  end

  


end