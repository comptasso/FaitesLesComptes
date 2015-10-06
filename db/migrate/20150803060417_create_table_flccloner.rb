class CreateTableFlccloner < ActiveRecord::Migration
  def change
    create_table :flccloner do |t|
      t.string :name
      t.integer :old_id
      t.integer :new_id
      t.integer :old_org_id
      t.integer :new_org_id
    end
  end
end
