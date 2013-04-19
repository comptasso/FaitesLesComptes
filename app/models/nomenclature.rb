# coding: utf-8



# Nomenclature enregistre dans ses 4 champs texte les informations permettant
# de construire les documents de bilan, Actif et Passif, le compte de Résultat
# ainsi que le compte de Benevolat.
#
# Un cinquième champ organism_id fait le lien avec l'organisme.
#
# Les validations concernent la présence de l'organisme et des trois documents
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

  serialize :actif, Hash
  serialize :passif, Hash
  serialize :resultat, Hash
  serialize :benevolat, Hash

  belongs_to :organism

  attr_accessible :actif, :passif, :resultat, :benevolat

  validates :actif, :passif, :resultat, :organism_id, :presence=>true
  validate :check_validity

  def instructions
    {:actif=>actif, :passif=>passif, :resultat=>resultat, :benevolat=>benevolat}
  end

  # remplit ses instructions à partir d'un fichier et se renvoie
  def load_file(file)
    yml = YAML::load_file(file)
    self.actif=yml[:actif]
    self.passif=yml[:passif]
    self.resultat=yml[:resultat]
    self.benevolat=yml[:benevolat]
    self
  end

  # remplit ses instructions à partir d'une chaine et se renvoie
  def load_io(io_string)
    yml = YAML::load(io_string)
    self.actif=yml[:actif]
    self.passif=yml[:passif]
    self.resultat=yml[:resultat]
    self.benevolat=yml[:benevolat]
    self
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