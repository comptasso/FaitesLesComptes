# coding: utf-8


# Classe pour construire une balance analytique. Une telle balance est 
# une collection de Destination dont chacune a ensuite une collection de 
# ligne avec des comptes, leur libellé et le total debit et crédit.
#
# La dernière destination regroupe les lignes qui n'ont pas de destinations
class Compta::AnalyticalBalance < ActiveRecord::Base
  
  include Utilities::PickDateExtension # apporte la méthode de classe pick_date_for
  
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :from_date, :string
  column :to_date, :string
  column :period_id, :integer
  
  
  
  attr_accessible :from_date, :to_date,  
    :period_id, :from_date_picker, :to_date_picker
  
   pick_date_for :from_date, :to_date # donne les méthodes from_date_picker 
  # et to_date_picker utilisées par le input as:date_picker 
   
   belongs_to :period
   
   validates :from_date, :to_date, :within_period=>true
   validates :from_date, :to_date, :period_id, :presence=>true
   
  
  def self.with_default_values(exercice)
    new(period_id:exercice.id, from_date:exercice.start_date, to_date:exercice.close_date)
  end
  
  def destinations
    period.organism.destinations
  end
  
  def lines
    @lines ||= collect_lines 
  end
  
  def total_debit
    lines.sum {|k, v| v[:debit]}
  end
  
  def total_credit
    lines.sum {|k, v| v[:credit]}
  end
  
  protected
  
  def collect_lines
    matable = {}
    destinations.each do |d|
      matable[d.name] = d.ab_lines(period_id, from_date, to_date)
    end
    matable['Sans Activité']={lines:orphan_lines, debit:orphan_debit, credit:orphan_credit}
    matable
  end
  
  # Récupère une table de comptes pour les compta_lines
  # qui n'ont pas de destination
  def orphan_lines
    @orphan_lines ||= Account.joins(:compta_lines=>:writing).
      select([:number, :title, "SUM(debit) AS t_debit", "SUM(credit) AS t_credit"]).
        where('destination_id IS NULL AND period_id = ? AND date >= ? AND date <= ?',
        period_id, from_date, to_date).
        group(:title,:number)
  end
  
  def orphan_debit
    orphan_lines.sum {|l| l.t_debit.to_d}
  end
  
  def orphan_credit
    orphan_lines.sum {|l| l.t_credit.to_d}
  end
end


