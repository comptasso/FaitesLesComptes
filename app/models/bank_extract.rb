# -*- encoding : utf-8 -*-

class BankExtract < ActiveRecord::Base
  include Utilities::PickDateExtension

  acts_as_tenant
  # utilise le module Utilities::PickDateExtension pour créer des virtual attributes
  # begin_date_picker et end_date_picker
  pick_date_for :begin_date, :end_date

  # attr_accessible :reference, :begin_date, :end_date, :begin_sold, :total_debit,
  #  :total_credit, :begin_date_picker, :end_date_picker

  # Valide que le close_date est bien postérieur au start_date
  class BankExtractChronoValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.begin_date && record.begin_date.is_a?(Date) && value && value.is_a?(Date)
        record.errors[attribute] << "la date de fin doit être postérieure à la date de début" if (value < record.begin_date)
      end
    end
  end

  belongs_to :bank_account
  has_many :bank_extract_lines, dependent: :destroy

  strip_before_validation :reference

  validates :reference, :format=>{with:NAME_REGEX}, :length=>{maximum:15}, :allow_blank=>true

  validates :begin_sold, :total_debit, :total_credit,:presence=>true, :numericality=>true, :two_decimals => true
  validates :begin_sold, :total_debit, :total_credit, :begin_date, :end_date , :cant_edit=>true, :if=>'locked'

  validates :begin_date, :end_date, :within_period=>true, :presence=>true
  validates :end_date, :bank_extract_chrono=>true

  # TODO n'est utile que la première fois
  before_save :lock_lines, :if=>'locked'

  scope :period, lambda {|p| where('begin_date >= ? AND end_date <= ?' ,
      p.start_date, p.close_date).order(:begin_date) }
  scope :unlocked, ->{where('locked = ?', false)}

  # indique si l'extrait est le premier de ce compte bancaire qui doive être pointé
  def first_to_point?
    return false if locked?
    id == bank_account.first_bank_extract_to_point.id
  end

  # un relevé est verrouillable s'il ne l'est pas déjà et si les
  # conditions d'égalité des lignes pointées sont vérifiées
  def lockable?
    !self.locked? && self.equality?
  end

  # calcul du solde final à partir des 3 autres données
  def end_sold
    begin_sold+total_credit-total_debit
  end

  # on utilise all.sum... car le champ debit et credit est en fait
  # dans la table compta_lines
  def total_lines_debit
    bank_extract_lines.joins(:compta_line).sum(:debit).to_d
  end

  # on utilise all.sum... car le champ debit et credit est en fait
  # dans la table compta_lines
  def total_lines_credit
    bank_extract_lines.joins(:compta_line).sum(:credit).to_d
  end

  # Il est normal que l'on est débit d'un côté et crédit de l'autre
  # car on est d'un côté avec le relevé de compte envoyé par la banque
  # et donc du point de vue de la banque; et de l'autre côté du point de
  # vue de la structure.
  def diff_debit
    total_debit - total_lines_credit
  end

  def diff_debit?
    diff_debit != 0
  end

  def diff_credit
    total_credit - total_lines_debit
  end

  def diff_credit?
    diff_credit != 0
  end

  # vérifie sir les montants debit et credit sont en ligne avec les
  # totaux des lignes du relevé
  def equality?
    (self.diff_debit.abs < 0.001) && (self.diff_credit.abs < 0.001)
  end

  # donne le solde à partir des lignes du relevé
  def lines_sold
    total_lines_credit - total_lines_debit
  end

  # doit être a zero lorsque tout est en ligne
  # mais ne suffit pas pour dire que tout est en ligne.
  def diff_sold
    begin_sold + lines_sold - end_sold
  end

  # retourne l'exercice correspondant à la date demandée, nil si pas trouvé
  def period
    bank_account.organism.find_period(begin_date) rescue nil
  end



  private

  # appelé par before save mais vérifie d'abord l'équality
  def lock_lines
    return false unless equality?
    bank_extract_lines.find_each {|bl| bl.lock_line}
  end



end
