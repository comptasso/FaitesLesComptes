class CreateCheckDeposits < ActiveRecord::Migration
  def change
    create_table :check_deposits do |t|
      t.integer :bank_account_id
      t.date :deposit_date

      t.timestamps
    end

    add_column :lines, :check_deposit_id, :integer
  end
end
