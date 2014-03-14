class RemoveUniqueIndexOnContinuousId < ActiveRecord::Migration
  def change
    remove_index :writings, :continuous_id
  end
end
