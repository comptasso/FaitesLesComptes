# coding: utf-8

# la class Archive est destinée à stocker un exercice comptable
# et à le restaurer
class Admin::Archive

  attr_reader :arch, :errors

  def initialize
    @errors=[]
  end
# FIXME voir si psych permet de vérifier la validité du fichier
  def parse_file(archive)
    @arch = YAML.load(archive)
  rescue
    @errors << "Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"
  end

 
  def list_errors
    self.errors.all.join('\n')
  end

  def valid?
    self.errors.count == 0 ? true : false
  end

  # on cherche l'organisme concerné par l'archive
  def organism
    @arch[:organism]
  end


  def organism_exists?
    Organism.where('title = ? ', self.organism.title).nil? ? false : true
  end



  def info
    info=''
    info += "L'organisme n'existe pas et sera donc créé lors de le restauration" unless self.organism_exists?
    info += "L'organisme existe et ne sera pas modifié lors de le restauration" if self.organism_exists?
  end



end
