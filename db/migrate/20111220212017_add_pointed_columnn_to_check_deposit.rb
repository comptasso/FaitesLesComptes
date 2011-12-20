class AddPointedColumnnToCheckDeposit < ActiveRecord::Migration
  def up
    add_column :check_deposits, :pointed, :boolean, default: false
    add_column :bank_extract_lines, :check_deposit_id, :integer
    remove_column :bank_extracts, :pointed
  end

  def down
    remove_column :check_deposits, :pointed
    remove_column :bank_extract_lines, :check_deposit_id
    add_column :bank_extracts, :pointed, :boolean, default: false
  end
end
