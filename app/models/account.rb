# coding: utf-8

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
  require 'pdf_document/base'

  belongs_to :period
  has_many :natures
  has_many :lines, :through=>:natures

  # la validator cant_change est dans le répertoire lib/validators
  validates :period_id, :title, :presence=>true
  validates :number, :presence=>true, :format=>{:with=>/\A[1-9]{1}[0-9]{1}[A-Z0-9]{0,8}\Z/}, :cant_change=>true
  validates_uniqueness_of :number, :scope=>:period_id

  # TODO être sur que period est valide (par exemple on ne doit pas
  # pouvoir ouvrir ou modifier un compte d'un exercice clos

  

  scope :classe, lambda {|i| where('number LIKE ?', "#{i}%")}
  scope :classe_6, where('number LIKE ?', '6%')
  scope :classe_7, where('number LIKE ?', '7%')
  scope :classe_6_and_7, where('number LIKE ? OR number LIKE ?', '6%', '7%')

   # le numero de compte plus le title pour les input select
  def long_name
   [number, title].join(' ')
  end

 

  # retourne le premier caractère du numéro de compte
  # attention classe avec un E, il s'agit d'une logique de comptable
  def classe
    self.number[0]
  end

  def cumulated_before(date, dc)
    self.lines.where('line_date < ?',date).sum(dc)
  end

   def cumulated_at(date, dc)
    self.lines.where('line_date <= ?',date).sum(dc)
  end

  # calcule le total des lignes de from date à to (date) inclus dans le sens indiqué par dc (debit ou credit)
  def movement(from, to, dc)
    self.lines.where('line_date >= ? AND line_date <= ?', from, to ).sum(dc)
  end

  def lines_empty?(from=self.period.start_date, to=self.period.close_date)
    self.lines.where('line_date >= ? AND line_date <= ?', from, to ).empty?
  end
  
  def all_lines_locked?(from=self.period.start_date, to=self.period.close_date)
    self.lines.where('line_date >= ? AND line_date <= ?', from, to ).any? {|l| !l.locked? } ? true : false
  end

  #produit un document pdf en s'appuyant sur la classe PdfDocument::Base
  # et ses classe associées page et table
  def to_pdf(from_date = period.start_date, to_date= period.close_date)
    stamp = "brouillard" unless all_lines_locked?(from_date, to_date)
    pdf = PdfDocument::Base.new(period, self,
      title:"Liste des écritures du compte #{number}",
      from_date:from_date, to_date:to_date,
      subtitle:"Du #{I18n::l from_date} au #{I18n.l to_date}",
      stamp:stamp)
    pdf.set_columns %w(line_date ref narration destination_id debit credit)
    pdf.set_columns_methods [nil, nil, nil, 'destination.name', nil, nil]
    pdf.set_columns_widths [10, 10, 40, 20, 10, 10]
    pdf.set_columns_titles %w(Date Réf Libellé Destination Débit Crédit)
    pdf.set_columns_to_totalize [4,5]
    pdf
  end



end
