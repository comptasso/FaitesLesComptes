# coding: utf-8

module Compta

  # la classe Listing sert à éditer un compte. Elle n'est pas persistente mais
  # s'appuie sur ActiveRecord::Base pour avoir les associations
  # Ceci suppose d'avoir une définition des colonnes virtuelles
  # d'om les premières lignes de cette classe
  class Listing < ActiveRecord::Base

    def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :from_date, :date
  column :to_date, :date
  column :account_id, :integer
  column :period_id, :integer

   belongs_to :period
   belongs_to :account
   has_many :accounts, :through=>:period

    include Utilities::PickDateExtension # apporte la méthode de classe pick_date_for

    pick_date_for :from_date, :to_date # donne les méthodes begin_date_picker et end_date_picker
  # utilisées par le input as:date_picker
   

   # je mets date_within_period en premier car je préfère les affichages Dates invalide ou hors limite
 # que obligatoire (sachant que le form n'affiche que la première erreur).
  validates :from_date, :to_date, date_within_period:true
  validates :from_date, :to_date, :account_id, :period_id, :presence=>true

  def lines
    @lines ||= fill_lines
  end

  
  def total_debit
    lines.sum(:debit)
  end

  def total_credit
    lines.sum(:credit)
  end

  def solde
    solde_credit_avant + total_credit - solde_debit_avant- total_debit
  end

  def solde_debit_avant
    lines.sum_debit_before(from_date)
  end

  def solde_credit_avant
    lines.sum_debit_before(from_date)
  end

  # to_pdf delegates to account to produce pdf data
  # use lib/pdf_document
  def to_pdf
    account.to_pdf(from_date, to_date)
  end


  protected

  def fill_lines
    @lines = account.lines.range_date(from_date, to_date)
  end

 end
end