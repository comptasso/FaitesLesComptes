# coding: utf-8


# la classe InOut est utilisée par le formulaire _new_line pour afficher les options de natures
#
# s'initialise avec un organism
# et le sens sous forme de symbole :recettes ou depenses
#
class Utilities::NaturesCollection
  def initialize(org, sens)
    @org = org
    @sens = sens
  end

  def name
    @sens.to_s.capitalize
  end

  def natures
    case @sens
    when :recettes then @org.natures.recettes.all
    when :depenses then @org.natures.depenses.all
    end
    
  end


end
