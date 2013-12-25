class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :day
      t.integer :mask_id
      t.date :end_date
      t.string :title
      t.integer :organism_id

      t.timestamps
    end
    
    add_index :subscriptions, :mask_id
  end
end
