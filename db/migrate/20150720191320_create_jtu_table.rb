class CreateJtuTable < ActiveRecord::Migration
  def change
    create_join_table :tenants, :users do |t|
      t.index [:tenant_id, :user_id]
    end
  end
end
