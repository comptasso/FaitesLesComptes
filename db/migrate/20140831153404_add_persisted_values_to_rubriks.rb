class AddPersistedValuesToRubriks < ActiveRecord::Migration
  def change
    add_column :rubriks, :period_id, :integer
    add_column :rubriks, :brut, :decimal, precision: 10, scale: 2,  default: 0
    add_column :rubriks, :amortissement, :decimal, precision: 10, scale: 2,  default: 0
    add_column :rubriks, :previous_net, :decimal, precision: 10, scale: 2,  default: 0
    
    add_column :nomenclatures, :job_finished_at, :datetime
  end 
end
