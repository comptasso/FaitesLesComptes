class AddDateIndexOnWritings < ActiveRecord::Migration
  def change
    add_index :writings, :date
  end
end
