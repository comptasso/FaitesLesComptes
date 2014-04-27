# La classe ImportedBel représente une ligne importée d'un relevé de compte 
# bancaire. 
# 
# Cette classe est ensuite destinée à créer des compta_line qui seront rattachés 
# à l'extrait bancaire correspondant. 
# 
# Ne pas confondre cette classe avec les BankExtractLines qui sont des lignes 
# faisant le lien entre un extrait de compte et les compta_lines. 
# 
# Les ImportedBel sont des objets à priori transitoires (une autre option de 
# programmation aurait été de les importer comme des BankExtractLines et de 
# les gérer dans la même table. 
# 
# Cette méthode n'a pas été retenue pour ne pas mettre dans la classe BankExtractLine
# trop de responsabilité. Et des perturbations éventuelles avec de nombreux imports 
# inaboutis. Il aurait par exemple fallu retirer le champ bank_extract_id des validations
# car une BankExtractLine doit appartenir à un bank_extract_id.
# 
# Un ImportedBel appartient à un compte bancaire
# 
#

class ImportedBel < ActiveRecord::Base
  
  attr_accessible :date, :narration, :debit, :credit, :position, :bank_account_id
  
  belongs_to 'bank_account'
  
  validates :date, :narration, presence:true
  validates :debit, :credit, presence:true, numericality:true, :not_null_amounts=>true, :not_both_amounts=>true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}

  
  
  
end