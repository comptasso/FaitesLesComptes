class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :number
      t.string :bank
      t.text :comment
      t.text :address
      t.date :opened_at
      t.integer :organism_id

      t.timestamps
    end
  end
end
