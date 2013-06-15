# coding: utf-8
require 'strip_arguments'

# 
# TODO ?ajouter un checksum md5 pour empêcher les modifs externes
#
# Archive est le modèle qui enregistre les sauvegardes effectuées
# Archive contient quelques méthodes utilitaires permettant de fournir
# au controller les informations utiles pour la construction du nom de fichier
#
# 
class Archive < ActiveRecord::Base
 
  belongs_to :organism
  
  attr_reader :collect

  attr_accessible :comment

  strip_before_validation :comment
  validates :comment, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :format=>{with:NAME_REGEX}, :allow_blank=>true

  # affiche le titre de l'archive à partir de l'organisme et de la date de création
  def title
    (organism.title + ' ' + created_at.to_s).split.join('_')
  end
  
  # le nom de fichier d une archive est constitué du nom de la base débarassé de ses chiffres de fin
  # auquel au rajoute un trait de soulignement et la date au format yyyymmjj
  #
  # Puis on ajoute l'extension sqlite3 ou dump selon l'adapter
  def archive_filename
    db = organism.database_name
    
    case adapter
    when 'sqlite3'
     "#{db} #{I18n.l(Time.now)}.sqlite3"
    when 'postgresql'
     "#{db} #{I18n.l(Time.now)}.dump"
    else
      raise Apartment::AdapterNotFound
    end
   end

  



  protected

  def adapter
    ActiveRecord::Base.connection_config[:adapter]
  end

  

end
