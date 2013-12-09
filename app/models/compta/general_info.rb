# coding: utf-8

# GeneralInfo est un module destiné à être inclus dans une classe sollicité pour 
# produire un pdf, ceci afin de pouvoir répondre aux besoins de base pour le pdf
module Compta::GeneralInfo
  
  def self.included(base)
    repond = base.class_eval('instance_methods.include? :period')
    base.class_eval(%Q(raise "La classe #{base} ne répond pas à period")) unless repond
  end
  
  
  
  def organism_name
    period.organism.title
  end

  def long_exercice
    period.long_exercice
  end
  
  def exercice
    long_exercice
  end
  
  def short_exercice
    period.short_exercice
  end

  
end
