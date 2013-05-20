# coding: utf-8
require 'strip_arguments'

# 
# TODO ?ajouter un checksum md5 pour empêcher les modifs externes
#
# Archive est le modèle qui enregistre les sauvegardes effectuées
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

  

end
