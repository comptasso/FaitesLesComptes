# remplace income_outcome de Nature par un book_id et met 
# à jour les natures existantes
class AddColumnBookIdToNatures < ActiveRecord::Migration
  def up
    add_column :natures, :book_id, :integer
    Nature.reset_column_information
    Nature.all.each {|n| fill_book_id(n)}
    remove_column :natures, :income_outcome
  end
  
  def down
    add_column :natures, :income_outcome, :boolean, default:false
    Nature.reset_column_information
    Nature.all.each {|n| fill_income_outcome(n)}
    remove_column :natures, :book_id
  end
  
  protected
  
  # si la nature est de type recettes, on met comme référence le premier livre de recettes
  # sinon, le premier livre de dépenses
  def fill_book_id(nature)
    bid = nature.income_outcome ? IncomeBook.first.id : OutcomeBook.first.id 
    nature.update_attribute(:book_id, bid)
  end
  
  def fill_income_outcome(nature)
    nio = nature.book.type == 'IncomeBook' ? true : false 
    nature.update_attribute(:income_outcome, nio)
  end
  
end
