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

  validates :actif, :passif, :resultat, :organism_id, :presence=>true
  validate :check_validity

  def instructions
    {:actif=>actif, :passif=>passif, :resultat=>resultat} 
  end

  def load_file(file)
    yml = YAML::load_file(file)
    self.actif=yml[:actif]
    self.passif=yml[:passif]
    self.resultat=yml[:resultat]
    self.benevolat=yml[:benevolat]
  end

  # crée une instance de Compta::Nomenclature pour l'exercice demandé
  def compta_nomenclature(period)
    Compta::Nomenclature.new(period, instructions)
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