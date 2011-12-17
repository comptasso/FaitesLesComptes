class RenameColumnBankToBankAccounts < ActiveRecord::Migration
  def change
    rename_column :bank_accounts, :bank, :name
  end

  
end
