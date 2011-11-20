# -*- encoding : utf-8 -*-

class Line < ActiveRecord::Base
  belongs_to :listing
  belongs_to :destination
  belongs_to :nature

  validates :debit, :credit, numericality: true
 

  default_scope order: 'line_date ASC'

  scope :mois, lambda { |date| where('line_date >= ? AND line_date <= ?', date.beginning_of_month, date.end_of_month) }
  scope :multiple, lambda {|copied_id| where('copied_id = ?', copied_id)}

  def self.solde_debit_avant(date)
    Line.where('line_date < ?', date).sum(:debit)
  end

  def self.solde_credit_avant(date)
    Line.where('line_date < ?', date).sum(:credit)
  end

  def repete(number, period)
    d=self.line_date
    t=[self]
    number.times do |i|
       case period
          when 'Semaines' then new_date = d+(i+1)*7
          when 'Mois' then new_date= d.months_since(i+1)
          when 'Trimestres' then new_date=d.months_since(3*(i+1))
        end
       t << self.copy(new_date)
       end
       t
    end

  
  # crée une ligne à partir d'une ligne existante en changeant la date
  def copy(new_date)
    l= self.dup
    l.line_date=new_date
    l
  end
  

  # before_validation :default_debit_credit
  #
  #
  #
  #  private
  #
  #  def default_debit_credit
  #    # ici il faudrait plutôt mettre à zero tout ce qui n'est pas un nombre
  #    debit ||= 0.0
  #    credit ||= 0.0
  #  end

  
end
