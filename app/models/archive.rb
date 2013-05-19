# coding: utf-8


# 
# TODO ?ajouter un checksum md5 pour empêcher les modifs externes
#
# Archive est le modèle qui enregistre les sauvegardes effectuées
# 
class Archive < ActiveRecord::Base
 
  belongs_to :organism
  
  attr_reader :collect

  attr_accessible :comment

  validates_length_of :comment, :maximum=>MAX_COMMENT_LENGTH
 
  # affiche le titre de l'archive à partir de l'organisme et de la date de création
  def title
    (organism.title + ' ' + created_at.to_s).split.join('_')
  end

  

end
