# coding: utf-8

class Transfer < ActiveRecord::Base

  belongs_to :organism
  belongs_to :debitable, :polymorphic=>true
  belongs_to :creditable, :polymorphic=>true

  validates :date, :amount, :presence=>true
  validates :debitable_id, :debitable_type, :presence=>true
  validates :creditable_id, :creditable_type, :presence=>true
  validates :amount, numericality: true
  # argument virtuel pour la saisie des dates

  validate :amount_cant_be_null, :required_fill_debitable, :required_fill_creditable
  validate :different_debit_and_credit

  def pick_date
    date ? (I18n::l date) : nil
  end

  def pick_date=(string)
    s = string.split('/')
    self.date = Date.civil(*s.reverse.map{|e| e.to_i})
  rescue ArgumentError
    self.errors[:date] << 'Date invalide'
    nil
  end

  # remplit les champs debitable_type et _id avec les parties 
  # model et id de l'argument.
  def fill_debitable=(model_id)
    elements = model_id.split('_')
    self.debitable_type = elements.first
    self.debitable_id = elements.last
  end

  def fill_debitable
    [debitable_type, debitable_id].join('_')
  end

  # remplit les champs creditable_type et _id avec les parties 
  # model et id de l'argument.
  def fill_creditable=(model_id)
    elements = model_id.split('_')
    self.creditable_type = elements.first
    self.creditable_id = elements.last
  end

  def fill_creditable
    [creditable_type, creditable_id].join('_')
  end

#  # trouve l'ensemble des transferts correspondant au modèle
#  # et au mois donné
#  def self.debitable_lines(model, month, year)
#    # TODO incorporer ensuite les limites month et year
#    begin_date = Date.civil(year, month, 1).beginning_of_month
#    end_date = begin_date.end_of_month
#    # récupérer les virements correspondants
#    Transfer.where('debitable_type = ? AND debitable_id = ?', model.class.name, model.id ).
#      where('date >= ? AND date <= ?').all
#  end
#
#  def self.creditable_lines(model, month, year)
#    # TODO incorporer ensuite les limites month et year
#    begin_date = Date.civil(year, month, 1).beginning_of_month
#    end_date = begin_date.end_of_month
#    # récupérer les virements correspondants
#    Transfer.where('debitable_type = ? AND debitable_id = ?', model.class.name, model.id ).
#      where('date >= ? AND date <= ?').all
#  end
#
#  
  # build_debit_line construit la ligne d'écriture débitrice à partir d'un virement
  #
  def build_debit_line
    if debitable_type == 'Cash'
      @cash_id = debitable_id
    elsif debitable_type == 'BankAccount'
      @bank_account_id = debitable_id
    end
    Line.new(:line_date=> date, :narration=>narration, :credit=> 0,
      :debit=>amount, :cash_id=> @cash_id, :bank_account_id=> @bank_account_id  )
  end
  
  # build_credit_line construit la ligne d'écriture créditrice à partir d'un
  # virement
  def build_credit_line
    if creditable_type == 'Cash'
      @cash_id = creditable_id
    elsif creditable_type == 'BankAccount'
      @bank_account_id = creditable_id
    end
    Line.new(:line_date=> date, :narration=>narration, :credit=>amount,
      :debit=>0, :cash_id=> @cash_id, :bank_account_id=> @bank_account_id  )
  end

  private

  def amount_cant_be_null
    errors.add :amount, 'nul !' if amount == 0
  end

  def required_fill_debitable
    errors.add :fill_debitable, 'champ obligatoire' if (debitable_id == nil || debitable_type == nil)
  end

  def required_fill_creditable
    errors.add :fill_creditable, 'champ obligatoire' if (creditable_id == nil || creditable_type == nil)
  end

  def different_debit_and_credit
    if fill_debitable == fill_creditable
      errors.add :fill_debitable, 'identiques !'
      errors.add :fill_creditable, 'identiques !'
    end
  end

end
