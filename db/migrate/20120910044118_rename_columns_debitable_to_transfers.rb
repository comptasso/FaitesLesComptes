class RenameColumnsDebitableToTransfers < ActiveRecord::Migration
  def up
    remove_column :transfers, :debitable_type
    remove_column :transfers, :creditable_type
    rename_column :transfers, :debitable_id, :to_account_id
    rename_column :transfers, :creditable_id, :from_account_id
  end

  def down
    add_column :transfers, :debitable_type, :string
    add_column :transfers, :creditable_type, :string
    rename_column :transfers, :to_account_id, :debitable_id
    rename_column :transfers, :from_account_id, :creditable_id
  end
end
