class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.date :line_date
      t.string :narration
      t.integer :nature_id
      t.integer :destination_id
      t.decimal :debit, precision: 10, scale: 2
      t.decimal :credit, precision: 10, scale: 2
      t.integer :listing_id
      t.boolean :locked, default: false

      t.timestamps
    end
  end
end
