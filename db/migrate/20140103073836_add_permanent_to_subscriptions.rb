class AddPermanentToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :permanent, :boolean, default:false
  end
end
