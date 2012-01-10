class CreateComptaAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :number
      t.string :title
      t.boolean :used, :default=>true
      t.integer :period_id

      t.timestamps
    end
  end
end
