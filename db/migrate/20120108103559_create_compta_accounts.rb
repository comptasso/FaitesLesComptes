class CreateComptaAccounts < ActiveRecord::Migration
  def change
    create_table :compta_accounts do |t|
      t.string :number
      t.string :title
      t.boolean :used
      t.integer :period_id

      t.timestamps
    end
  end
end
