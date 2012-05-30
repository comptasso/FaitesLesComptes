class AddBankExtractIdToCheckDeposits < ActiveRecord::Migration

  # migration destinée à changer le sens de la
  def up
    add_column :check_deposits, :check_deposit_bank_extract_line_id, :integer
    remove_column :bank_extract_lines, :check_deposit_id

  end

  def down
    remove_column :check_deposits, :bank_extract_line_id
    add_column :bank_extract_lines, :check_deposit_id, :integer
  end
end
