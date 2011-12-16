class AddColumnnCashIdToLines < ActiveRecord::Migration
  def change
    add_column :lines, :cash_id, :integer
    add_column :lines, :bank_account_id, :integer
  end
end
