class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :periods do |t|
      t.date :start_date
      t.date :close_date
      t.integer :organism_id
      t.boolean :open

      t.timestamps
    end
  end
end
