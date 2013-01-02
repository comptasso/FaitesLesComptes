# coding: utf-8


load 'pdf_document/account.rb'

module Compta



  # la classe Listing sert à éditer un compte. Elle n'est pas persistente mais
  # s'appuie sur ActiveRecord::Base pour avoir les associations
  # Ceci suppose d'avoir une définition des colonnes virtuelles
  # d'où les premières lignes de cette classe
  class Listing < ActiveRecord::Base

    include Utilities::Sold
    include Utilities::ToCsv

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

  # donne le cumul du débit ou du crédit (sens) à une date donnée
  delegate :cumulated_at, :to=>:account


  def with_default_values
    self.from_date ||= period.start_date
    self.to_date ||= period.close_date
    self
  end

  def solde_debit_avant
    cumulated_debit_before(from_date)
  end

  def solde_credit_avant
    cumulated_credit_before(from_date)
  end

  def total_debit
    movement(from_date, to_date, 'debit')
  end

  def total_credit
    movement(from_date, to_date, 'credit')
  end


  def lines
    @lines ||= account.compta_lines.listing(from_date, to_date)
  end

  # permet notamment de contrôler les limites de date
  def period
    account.period if account
  end

  # utile pour le formulaire de saisie pour changer de compte
  def accounts
    period.accounts
  end

  def to_csv(options = {col_sep:"\t"})
    CSV.generate(options) do |csv|
        csv << ["Liste des écritures du compte #{account.number}",'', '',  '', '', '','', '']
        csv << %w(Date Journal Référence Libellé Nature Destination Débit Crédit)
        csv << ["Soldes au #{I18n::l from_date}",'', '', '', '','', reformat(solde_debit_avant), reformat(solde_credit_avant) ]
        lines.each do |l|
          csv << [I18n::l(l.date), l.book.title, l.ref, l.narration, l.nature_name, l.destination_name, reformat(l.debit), reformat(l.credit)]
        end
        csv << ['Totaux', '', '', '', '','', reformat(total_debit), reformat(total_credit)]
        csv << ["Soldes au #{I18n::l to_date}", '', '', '', '','', reformat(solde_debit_avant + total_debit), reformat(solde_credit_avant + total_credit)]
      end
  end

 
  #produit un document pdf en s'appuyant sur la classe PdfDocument::Default
  # et ses classe associées page et table
  def to_pdf(options = {})
    options[:title] ||=  "Liste des écritures du compte #{account.number}"
    options[:subtitle] ||= "Du #{I18n::l from_date} au #{I18n.l to_date}"
    options[:stamp] = "brouillard" unless account.all_lines_locked?(from_date, to_date)
    options[:from_date] = from_date
    options[:to_date] = to_date
    pdf = PdfDocument::Account.new(period, account, options)

    pdf.set_columns ['writings.date AS w_date', 'books.title AS b_title', 'writings.ref AS w_ref', 'writings.narration AS w_narration', 'nature_id', 'destination_id', 'debit',  'credit']
    pdf.set_columns_methods ['w_date', 'b_title', 'w_ref', 'w_narration', 'nature.name', 'destination.name', nil, nil]
    pdf.set_columns_widths [10, 8, 8, 24, 15, 15, 10, 10]
    pdf.set_columns_titles %w(Date Jnl Réf Libellé Nature Destination Débit Crédit)
    pdf.set_columns_to_totalize [6,7]
    pdf.first_report_line = ["Soldes au #{I18n::l from_date}"] + account.formatted_sold(from_date)
    pdf
  end

  protected

  # remplace les points décimaux par des virgules pour s'adapter au paramétrage
    # des tableurs français
    def reformat(number)
      sprintf('%0.02f',number).gsub('.', ',') if number
    end




 end
end