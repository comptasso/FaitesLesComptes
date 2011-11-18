class ChangeColumnDebitToLines < ActiveRecord::Migration
  def up
    change_table :lines do |t|
    t.change_default  :debit, default: 0
     t.change_default :credit, default: 0
  end
  end

  def down
  end
end
