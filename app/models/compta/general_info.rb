# coding: utf-8

# GeneralInfo est un module destiné à être inclus dans une classe sollicité pour 
# produire un pdf, ceci afin de pouvoir répondre aux besoins de base pour le pdf
module Compta::GeneralInfo
  def organism_name
    period.organism.title
  end

  def exercice
    period.exercice
  end

  
end
