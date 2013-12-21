# coding: utf-8

# Modèle déstiné à produire le Fichier des Ecritures Comptables (FEC)
# d'où le nom du modèle qui est exigé par le Ministère des Finances 
# pour toute comptabilité informatisée.
#
class Extract::Fec < ActiveRecord::Base
  
  FEC_TITLES = [  # selon la nomenclature de l'arrêté du 29 juillet 2013
	'JournalLib',
	'EcritureNum',
	'EcritureDate',
	'CompteNum',
	'CompteLib',
	'CompAuxNum',
	'CompAuxLib',
	'PieceRef',
	'PieceDate',
		'EcritureLib',
	'Debit',
	'Credit',
	'EcritureLet',
	'DateLet',
	'ValidDate',
	'Montantdevise',
	'Idevise',
  'DateRglt', 
  'ModeRglt',
  'NatOp']
  
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :period_id, :integer
    
  belongs_to :period
  
  # on n'utilise pas has_many car on a besoin du unscoped pour retirer l'ordre 
  # des lignes qui est présent dans le modèle ComptaLine.
  def lines
    ComptaLine.unscoped.includes([:account, :writing => :book]).
      where('period_id =  ?', period_id).order('writings.continuous_id ASC', 'compta_lines.id')
  end
  
#  has_many :lines, :through=>:period, source: :compta_lines, :include=>[:account, :writing => :book], 
#    :order=>'writings.continuous_id', readonly: :true
  
  def to_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << FEC_TITLES
        lines.each {|line| csv << to_fec(line) }
        
      end
    end
  
  def to_fec(row)
     [row.book.abbreviation, # code journal 
       row.book.title, # Libellé journal
         row.writing.continuous_id, # numéro sur une séquence continue de l'écriture comptable
        I18n::l(row.writing.updated_at.to_date), # date de comptabilisation de l'écriture
       row.account.number, # numéro de compte
       row.account.title, # libellé du compte
        '', # numéro de compte auxiliaire
        '', # libellé du compte auxiliaire
        row.writing.ref || '', # référence de la pièce justificative
        '', # date de la pièce justificative
        row.writing.narration, # libellé de l'écriture comptable
        ActionController::Base.helpers.number_with_precision(row.debit, precision:2), # debit
        ActionController::Base.helpers.number_with_precision(row.credit, precision:2), # credit
        '', '', # lettrage et date de lettrage
        I18n::l(row.writing.updated_at.to_date), # date de comptabilisation (on utilise updated_at provisoirement
        # en attendant de rajouter un champ locked_at 
        '', '', #montant en devise et identifiant de la devise
        I18n::l(row.writing.date), # date du règlement pour les compta de trésorerie
        row.writing.payment_mode, # mode de règlement
        '' # nature de l'opération - est inutilisé
        ]
  end
end
