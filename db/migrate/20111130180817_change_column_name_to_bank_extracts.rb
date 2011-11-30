class ChangeColumnNameToBankExtracts < ActiveRecord::Migration
  def up
    change_table :bank_extracts do |t|
      t.rename :validated, :locked
    end
  end

  def down
     change_table :bank_extracts do |t|
      t.rename :locked, :validated
    end

  end
end
