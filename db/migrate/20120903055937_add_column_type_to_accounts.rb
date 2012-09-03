class AddColumnTypeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :accountable_type, :string
    add_column :accounts, :accountable_id, :integer
  end
end
