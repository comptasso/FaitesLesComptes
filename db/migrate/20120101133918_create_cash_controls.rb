class CreateCashControls < ActiveRecord::Migration
  def change
    create_table :cash_controls do |t|
      t.integer :cash_id
      t.decimal :amount
      t.date :date

      t.timestamps
    end
  end
end
