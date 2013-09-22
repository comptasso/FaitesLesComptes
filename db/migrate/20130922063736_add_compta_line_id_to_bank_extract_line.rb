# Cette migration est destinée à se passer de la relation habtm 
# entre les compta_line et les bank_extract_lines. 
#
# Cette relation avait été mise en place pour 
class AddComptaLineIdToBankExtractLine < ActiveRecord::Migration
  def up
    #add_column :bank_extract_lines, :compta_line_id, :references
  end
  
  def down
    #remove_column :bank_extract_lines, :compta_line_id
  end
end
