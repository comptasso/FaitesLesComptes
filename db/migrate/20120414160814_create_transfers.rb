class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.date :date
      t.string :narration
      t.references :debitable, :polymorphic=>true
      t.references :creditable, :polymorphic=>true
      t.integer :organism_id
      t.decimal :amount, scale: 10, precision: 2

      t.timestamps
    end
  end
end
