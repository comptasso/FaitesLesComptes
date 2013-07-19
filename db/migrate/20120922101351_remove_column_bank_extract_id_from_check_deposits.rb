class RemoveColumnBankExtractIdFromCheckDeposits < ActiveRecord::Migration
  def up
    # remove_column :check_deposits, :bank_extract_id
  end

  def down
    # add_column :check_deposits, :bank_extract_id, :integer
  end
end
