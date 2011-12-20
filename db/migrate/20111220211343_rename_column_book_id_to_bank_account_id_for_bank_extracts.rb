class RenameColumnBookIdToBankAccountIdForBankExtracts < ActiveRecord::Migration
  def up
    rename_column :bank_extracts,  :book_id, :bank_account_id
  end

  def down
    rename_column :bank_extracts, :bank_account_id, :book_id
  end
end
