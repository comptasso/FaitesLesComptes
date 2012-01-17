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


class Account < ActiveRecord::Base
  belongs_to :period
  has_many :natures
  has_many :lines, :through=>:natures

   # la validator cant_change est dans le fichier specific_validator.rb
  validates :number, :presence=>true, :format=>{:with=>/\A[1-9]{1}[0-9]{1}[A-Z0-9]{0,8}\Z/}, :cant_change=>true

  validates_uniqueness_of :number, :scope=>:period_id

  # TODO être sur que period est valide (par exemple on ne doit pas
  # pouvoir ouvrir ou modifier un compte d'un exercice clos

  # TODO ce validates semble empêcher le fonctionnement de Factory
  validates :period_id, :presence=>true
  validates :title, :presence=>true

  scope :classe_6, where('number LIKE ?', '6%')
  scope :classe_7, where('number LIKE ?', '7%')
  scope :classe_6_and_7, where('number LIKE ? OR number LIKE ?', '6%', '7%')

   # le numero de compte plus le title pour les input select
  def long_name
   [number, title].join(' ')
  end

  # retourne le premier caractère du numéro de compte
  def classe
    self.number[0]
  end

  def cumulated_before(date, dc)
    self.lines.where('line_date < ?',date).sum(dc)
  end

   def cumulated_at(date, dc)
    self.lines.where('line_date <= ?',date).sum(dc)
  end

   # le total debit pour un jour donné
  def debit(date)
self.lines.where('line_date=?',date).sum(:debit)
  end

  # le total crédit pour un jour donné
  def credit(date)
self.lines.where('line_date=?',date).sum(:credit)
  end

  # calcule le total des lignes de from date à to (date) inclus dans le sens indiqué par dc (debit ou credit)
  def movement(from, to, dc)
    self.lines.where('line_date >= ? AND line_date <= ?', from, to ).sum(dc)
  end




end
