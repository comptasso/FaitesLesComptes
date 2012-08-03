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
  
   
   belongs_to :account
   

    include Utilities::PickDateExtension # apporte la méthode de classe pick_date_for

    pick_date_for :from_date, :to_date # donne les méthodes begin_date_picker et end_date_picker
  # utilisées par le input as:date_picker
   

   # je mets date_within_period en premier car je préfère les affichages Dates invalide ou hors limite
 # que obligatoire (sachant que le form n'affiche que la première erreur).
  validates :from_date, :to_date, date_within_period:true
  validates :from_date, :to_date, :account_id, :presence=>true

  def with_default_values
    self.from_date ||= period.start_date
    self.to_date ||= period.close_date
    self
  end

  def lines
    account.lines.range_date(from_date, to_date)
  end

  # permet notamment de contrôler les limites de date
  def period
    account.period if account
  end

  # utile pour le formulaire de saisie pour changer de compte
  def accounts
    period.accounts
  end

  
  def total_debit
    lines.sum(:debit)
  end

  def total_credit
    lines.sum(:credit)
  end


  def solde_final
    solde_credit_avant + total_credit - solde_debit_avant- total_debit
  end

  def solde_debit_avant
    account.lines.sum_debit_before(from_date)
  end

  def solde_credit_avant
    account.lines.sum_credit_before(from_date)
  end
  

  def to_pdf(options = {})
    account.to_pdf(from_date, to_date, options)
  end

#
#  def to_pdf(options = {})
#    account.to_pdf(from_date, to_date, options)
#  end

  #produit un document pdf en s'appuyant sur la classe PdfDocument::Base
  # et ses classe associées page et table
  def to_pdf(options = {})
    options[:title] ||=  "Liste des écritures du compte #{account.number}"
    options[:subtitle] ||= "Du #{I18n::l from_date} au #{I18n.l to_date}"
    options[:stamp] = "brouillard" unless account.all_lines_locked?(from_date, to_date)
    options[:from_date] = from_date
    options[:to_date] = to_date
    pdf = PdfDocument::Base.new(period, account, options)

    pdf.set_columns %w(line_date ref narration nature_id destination_id debit credit)
    pdf.set_columns_methods [nil, nil, nil, 'nature_name', 'destination_name', nil, nil]
    pdf.set_columns_widths [10, 8, 32, 15, 15, 10, 10]
    pdf.set_columns_titles %w(Date Réf Libellé Nature Destination Débit Crédit)
    pdf.set_columns_to_totalize [5,6]
    pdf.first_report_line = ["Soldes au #{I18n::l from_date}"] + account.formatted_sold(from_date)
    pdf
  end

  # méthode utilisée pour insérer le listing d'un compte dans un autre pdf
  # notamment pour le grand livre
  def render_pdf_text(other_pdf)
    to_pdf.render_pdf_text(other_pdf)
  end


 end
end