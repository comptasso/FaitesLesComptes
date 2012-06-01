class RenameBankExtractLineToCheckDeposits < ActiveRecord::Migration
  def change
    rename_column :check_deposits, :check_deposit_bank_extract_line_id, :bank_extract_line_id
  end
end
