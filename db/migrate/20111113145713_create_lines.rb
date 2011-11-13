class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.date :date
      t.string :narration
      t.integer :nature_id
      t.integer :destination_id
      t.decimal :debit
      t.decimal :credit
      t.integer :listing_id
      t.boolean :locked

      t.timestamps
    end
  end
end
