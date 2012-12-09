# coding: utf-8

# Controller permettant d'afficher les différentes pages existant pour la nomenclature retenue
# actif, passif, ...

class Compta::NomenclaturesController < Compta::ApplicationController

  def show
    @pages =  Compta::Nomenclature.new(@period).pages
  end


 
end

