class RemoveColumnBookIdToCashAndBankAccount < ActiveRecord::Migration
  def up
    remove_column :cashes, :book_id
    remove_column :bank_accounts, :book_id
    rename_column :bank_accounts, :name, :bank_name
  end

  def down
    add_column :cashes, :book_id, :integer
    add_column :bank_accounts, :book_id, :integer
    rename_column :bank_accounts, :bank_name, :name
  end
end
