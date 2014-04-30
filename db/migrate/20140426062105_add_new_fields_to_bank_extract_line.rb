# ce nom est tout à fait inadapté. Il devrait être CreateImportedBels
class AddNewFieldsToBankExtractLine < ActiveRecord::Migration
  def change
    create_table :imported_bels do |t|
      t.integer :position
      t.date :date
      t.string :narration
      t.decimal  :debit, precision: 10, scale: 2
      t.decimal :credit,  precision: 10, scale: 2
      t.integer :bank_account_id
      
      t.timestamps
    end
    
    
  end
  
end
