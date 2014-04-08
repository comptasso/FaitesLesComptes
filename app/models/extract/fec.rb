# coding: utf-8

# Modèle déstiné à produire le Fichier des Ecritures Comptables (FEC)
# d'où le nom du modèle qui est exigé par le Ministère des Finances 
# pour toute comptabilité informatisée.
#
class Extract::Fec < ActiveRecord::Base
  
  FEC_TITLES = [  # selon la nomenclature de l'arrêté du 29 juillet 2013 
    'JournalCode',  
    'JournalLib',  #champ 2
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
    'ValidDate', # champ 15
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
  
  def to_csv(options = {col_sep:"\t"})
    CSV.generate(options) do |csv|
      csv << FEC_TITLES
      lines.each {|line| csv << to_fec(line) }
    end
  end
  
  def to_fec(row)
    [row.book.abbreviation, # code journal 
      row.book.title, # Libellé journal
      row.writing.continuous_id || '', # numéro sur une séquence continue de l'écriture comptable
      format_timestamp(row.writing.created_at), # date de comptabilisation de l'écriture
      row.account.number, # numéro de compte
      row.account.title, # libellé du compte
      '', # numéro de compte auxiliaire
      '', # libellé du compte auxiliaire
      row.writing.ref || '', # référence de la pièce justificative
      format_date(row.writing.ref_date), # date de la pièce justificative
      row.writing.narration, # libellé de l'écriture comptable
      format_amount(row.debit),  # debit
      format_amount(row.credit), # credit
      '', '', # lettrage et date de lettrage
      format_date(row.writing.locked_at), # date de verrouillage
      '', '', #montant en devise et identifiant de la devise
      format_date(row.writing.date), # date du règlement pour les compta de trésorerie
      row.writing.payment_mode || '', # mode de règlement
      '' # nature de l'opération - est inutilisé
    ]
  end
  
  
  private
  
  # pour sortir au format français (virgule et séparateur de milliers)
  def format_amount(amount)
    ActionController::Base.helpers.number_with_precision(amount, precision:2)
  end
  
  # pour ne retenir que la date, ou blanc si pas de date
  # alias format_date permet d'utiliser le nom qui parait le plus en relation 
  # avec le type du champ (timestamp pour created_at et updated_at, date
  # pour date, ref_date et locked_at.
  def format_timestamp(timestamp)
    timestamp ? I18n::l(timestamp.to_date) : ''
  end
  
  alias format_date format_timestamp
end
