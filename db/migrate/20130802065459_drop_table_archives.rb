class DropTableArchives < ActiveRecord::Migration
  def up
    drop_table "archives" 
  end

  def down
    create_table "archives", :force => true do |t|
    t.integer  "organism_id", :null => false
    t.string   "comment"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end
  end
end
