class RemoveColumnOpenedAtToBankAccounts < ActiveRecord::Migration
  def change
    remove_column :bank_accounts, :opened_at, :date
  end

  
end
