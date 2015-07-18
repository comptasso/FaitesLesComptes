class AddPieceNumberToWriting < ActiveRecord::Migration
  def change
    add_column :writings, :piece_number, :integer
    
    Writing.reset_column_information
    
    Writing.connection.execute('UPDATE writings SET piece_number = id')

  end
end
