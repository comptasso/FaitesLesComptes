class CreateWritings < ActiveRecord::Migration
  def change
    create_table :writings do |t|
      t.date :date
      t.string :narration
      t.string :ref
      t.integer :book_id
      t.timestamps
    end
  end
end
