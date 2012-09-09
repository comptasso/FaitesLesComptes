class AddColumnBookIdToCashes < ActiveRecord::Migration
  def change
    add_column :cashes, :book_id, :integer
    add_column :bank_accounts, :book_id, :integer
  end
end
