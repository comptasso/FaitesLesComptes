# coding: utf-8


# la classe InOut est utilisée par le formulaire _new_line pour afficher les options de natures
#
# s'initialise avec un exercice
# et le sens sous forme de symbole :recettes ou depenses
#
class Utilities::NaturesCollection
  def initialize(period, book)
    @period = period
    @book = book
  end
  
  def name
    @book.title.capitalize
  end

  def natures
    @book.natures.within_period(@period)    
  end


end
