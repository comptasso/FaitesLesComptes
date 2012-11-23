class AddPrecisionToComptaLines < ActiveRecord::Migration
  def up
    remove_column :compta_lines, :debit
    add_column :compta_lines, :debit, :decimal, :precision=>10, :scale=>2, :default=>0
    remove_column :compta_lines, :credit
    add_column :compta_lines, :credit,:decimal,  :precision=>10, :scale=>2, :default=>0
    remove_column :bank_extracts, :begin_sold
    add_column :bank_extracts, :begin_sold,:decimal,  :precision=>10, :scale=>2, :default=>0
    remove_column :bank_extracts, :total_debit
    add_column :bank_extracts, :total_debit,:decimal,  :precision=>10, :scale=>2, :default=>0
    remove_column :bank_extracts, :total_credit
    add_column :bank_extracts, :total_credit,:decimal,  :precision=>10, :scale=>2, :default=>0
    remove_column :cash_controls, :amount
    add_column :cash_controls, :amount, :decimal, :precision=>10, :scale=>2, :default=>0
  end

  def down

  end
end
