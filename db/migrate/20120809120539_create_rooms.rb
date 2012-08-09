class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :user_id
      t.string :database_name

      t.timestamps
    end
  end
end
