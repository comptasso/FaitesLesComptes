# Cette migration est destinée à se passer de la relation habtm 
# entre les compta_line et les bank_extract_lines. 
#
# Cette relation avait été mise en place pour pouvoir pointer plusieurs
# écritures avec une seule ligne de relevé (cas de tickets de péage par exemple)
# Mais en fait, on simplifie. L'utilisateur pourra au choix, regrouper ses 
# écritures de péages en une seule, ou agrafer ensemble les différents tickets 
# et noter une mention sur son relevé.

# par ailleurs, la date n'est pas utilisée donc on en profite pour retirer ce champ inutilisé
class AddComptaLineIdToBankExtractLine < ActiveRecord::Migration
  def up
    add_column :bank_extract_lines, :compta_line_id, :integer
    remove_column :bank_extract_lines, :date
    
    drop_table :bank_extract_lines_lines
    
    add_index "bank_extract_lines", ["compta_line_id"], :name => "index_bank_extract_lines_on_compta_line_id"
    
    
  end
  
  def down
    remove_column :bank_extract_lines, :compta_line_id
    add_column :bank_extract_lines, :date, :date
    
    create_table :bank_extract_lines_lines, :id=>false do |t|
      t.references :bank_extract_line
      t.references :line
    end
    
    remove_index :bank_extract_lines, :compta_line_id 
    
  end
end
