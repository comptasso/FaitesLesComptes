class RemoveTableTransfers < ActiveRecord::Migration
  def up
    drop_table :transfers
  end
 
  def down
     create_table "transfers", :force => true do |t|
    t.date     "date"
    t.string   "narration"
    t.integer  "to_account_id"
    t.integer  "from_account_id"
    t.integer  "organism_id"
    t.decimal  "amount",          :precision => 2, :scale => 10
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end
  end
end
