class AddColumnAccountIdToLines < ActiveRecord::Migration
  def change
    add_column :lines, :account_id, :integer
    add_index :lines, :account_id

  end
end
