class AddWritingIdToCheckDeposits < ActiveRecord::Migration
  def change
    add_column :check_deposits, :writing_id, :integer

  end
end
