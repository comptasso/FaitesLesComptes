# This migration comes from adherent (originally 20130808054023)
class CreateAdherentPayments < ActiveRecord::Migration
  def change
    create_table :adherent_payments do |t|
      t.date :date
      t.decimal :amount, precision: 10, scale: 2
      t.string :mode
      
      t.references :member

      t.timestamps
    end
    
    add_index :adherent_payments, :member_id
    
    
  end
end
