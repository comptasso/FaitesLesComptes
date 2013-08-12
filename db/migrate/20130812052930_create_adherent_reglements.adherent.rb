# This migration comes from adherent (originally 20130809052125)
class CreateAdherentReglements < ActiveRecord::Migration
  def change
    create_table :adherent_reglements do |t|
      t.decimal :amount, precision: 10, scale: 2
      t.references :adhesion
      t.references :payment

      t.timestamps
    end
    add_index :adherent_reglements, :adhesion_id
    add_index :adherent_reglements, :payment_id
  end
end
