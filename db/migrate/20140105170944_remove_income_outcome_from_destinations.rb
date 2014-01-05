class RemoveIncomeOutcomeFromDestinations < ActiveRecord::Migration
  def up
    remove_column :destinations, :income_outcome
  end

  def down
    add_column :destinations, :income_outcome, :default => false 
  end
end
