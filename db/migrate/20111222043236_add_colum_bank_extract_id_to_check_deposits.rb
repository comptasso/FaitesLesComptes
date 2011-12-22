class AddColumBankExtractIdToCheckDeposits < ActiveRecord::Migration
  def up
    add_column :check_deposits, :bank_extract_id, :integer
    remove_column :check_deposits, :pointed
  end

  def down
    remove_column :check_deposits, :bank_extract_id
    add_column :check_deposits, :pointed, :boolean
  end
end
