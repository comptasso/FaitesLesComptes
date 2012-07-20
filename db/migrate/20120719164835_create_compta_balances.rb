class CreateComptaBalances < ActiveRecord::Migration
  def change
    create_table :compta_balances do |t|
      t.date :from_date
      t.date :to_date
      t.integer :from_account_id
      t.integer :to_account_id
      t.integer :period_id

      t.timestamps
    end
  end
end
