class RemoveColumnAccountableIdFromBankAccounts < ActiveRecord::Migration
  def up
   
    remove_column :lines, :cash_id
    remove_column :lines, :bank_account_id
    remove_column :lines, :multiple
    remove_column :lines, :copied_id
  end

  def down
    
    

    add_column :lines, :cash_id, :integer
    add_column :lines, :bank_account_id, :integer
    add_column :lines, :multiple, :boolean
    add_column :lines, :copied_id, :string
  end
end
