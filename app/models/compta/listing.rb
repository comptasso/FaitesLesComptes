# coding: utf-8

module Compta
  class Listing < ActiveRecord::Base

    def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :from_date, :string
  column :to_date, :string
  column :account_id, :integer
  column :period_id, :integer

   belongs_to :period
   belongs_to :account

    include Utilities::PickDateExtension # apporte la méthode de classe pick_date_for

    pick_date_for :from_date, :to_date # donne les méthodes begin_date_picker et end_date_picker
  # utilisées par le input as:date_picker
   attr_reader :lines, :solde_debit_avant, :solde_credit_avant, :total_debit, :total_credit, :solde

   # je mets date_within_period en premier car je préfère les affichages Dates invalide ou hors limite
 # que obligatoire (sachant que le form n'affiche que la première erreur).
  validates :from_date, :to_date, date_within_period:true
  validates :from_date, :to_date, :account_id, :period_id, :presence=>true

  def fill_lines
    @lines = account.lines.range_date(from_date, to_date)
    fill_soldes
  end

  protected

  def fill_soldes
    @solde_debit_avant=account.lines.solde_debit_avant(from_date)
    @solde_credit_avant=account.lines.solde_credit_avant(from_date)
    @total_debit=@lines.sum(:debit)
    @total_credit=@lines.sum(:credit)
    @solde= @solde_credit_avant+@total_credit-@solde_debit_avant-@total_debit
  end



end
end