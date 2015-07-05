class AddDatePieceToWritings < ActiveRecord::Migration
  def change
    add_column :writings, :date_piece, :date
  end
end
