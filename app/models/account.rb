# classe des comptes
#
# Règles : on ne peut pas modifier un numéro de compte - utilise cant_change validator
# qui est dans le fichier specific_validator
#

# Les comptes peuvent être actifs ou non. Etre actif signifie qu'on peut
# enregistrer des écritures. Ainsi les comptes 10, 20 ...
# ne doivent a priori pas être actifs. Dans la vue index, ils sont en gris et en gras.


# TODO dans tous les modèles qui utilisent décimal rajouter précision
# et scale puisque le guide Rails(p.392) le recommande très fortement

# TODO gestion des Foreign keys cf. p 400 de Agile Web Development

require "#{Rails.root}/app/models/specific_validator"

class Account < ActiveRecord::Base
  belongs_to :period

   # la validator cant_change est dans le fichier specific_validator.rb
  validates :number, :presence=>true, :format=>{:with=>/\A[1-9]{1}[0-9]{1}[A-Z0-9]{0,8}\Z/}, :cant_change=>true

  validates_uniqueness_of :number, :scope=>:period_id

  # TODO être sur que period est valide (par exemple on ne doit pas
  # pouvoir ouvrir ou modifier un compte d'un exercice clos

  # TODO ce validates semble empêcher le fonctionnement de Factory
  validates :period_id, :presence=>true
  validates :title, :presence=>true



end
