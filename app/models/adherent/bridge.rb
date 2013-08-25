
# La classe Adherent::Bridge fait le pont avec le gem Adherent. Elle est utilisée
# par Adherent::PaymentObserver qui enregistre dans le module compta les payments 
# qui sont entrés dans le module Adhérent.
# 
# Un enregistrement est créé lors de la création d'un organisme. L'utilisateur 
# peut ensuite modifier les valeurs de cet enregistrement. 
# 
# La classe peut renvoyer les différentes valeurs qui sont nécessaires pour passer
# une recette Cotisation. Elle a besoin pour celà de la date puisque la nature 
# est dépendante de l'exercice.
#
class Adherent::Bridge < ActiveRecord::Base
  attr_accessible :bank_account_id, :cash_id, :destination_id, :income_book_id, :nature_name
  
  belongs_to :organism
  belongs_to :bank_account
  belongs_to :cash
  belongs_to :income_book
  belongs_to :destination
  
  validates :destination_id, :nature_name, :income_book_id, :cash_id, 
    :bank_account_id, :organism_id, :presence=>true
  
  # renvoie les valeurs nécessaires pour que le PaymentObserver puisse passer
  # l'écriture de payment
  def payment_values(date) 
    
  end
end
