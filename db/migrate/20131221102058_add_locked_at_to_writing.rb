class AddLockedAtToWriting < ActiveRecord::Migration
  def change
    add_column :writings, :locked_at, :date
    add_column :writings, :ref_date, :date
  end
end
