# coding: utf-8

# Coherent vérifie que les champs désignés par l'option with
# appartiennent bien à l'exercice couvrant la date sur laquelle porte la vérification.
#
# Ce validator permet de vérifier la cohérence entre un champ d'un record et
# un ou des champs d'un record enfant, notamment dans le cas de nested_attributes
#
# Par exemple, pour le modèle Writing, il est nécessaire que la date, qui est dans 
# Writing soit dans un exercice, et que les comptes et les natures qui sont
# dans des compta_lines dépendant de Writing soit dans le même exercice. 
# 
# Cela donne 
#   validates :date, :coherent=>{:nested=>:compta_lines, :fields=>[:nature, :account]}
#
# L'argument de fields peut être unique ou être un Array
#
# Le modèle doit répondre à Period avec value comme argument; en l'occurence, sur l'exemple
# donné, writing doit répondre à period.
#
class PeriodCoherentValidator < ActiveModel::EachValidator

  # pour lire l'option
  def initialize(options)
    @fields = options[:with]
    super
  end

  # Trouve la period puis pour chacun
  # des champs de l'option :fields, appelle
  # la méthode check_field
  #
  def validate_each(record, attribute, value)
      period = find_period(record, value) 
      # flatten pour pouvoir accepter dans l'option :fields un seul élément ou un Array
     [@fields].flatten.each do |field|
       other_value = record.send(field)
       other_period = find_period(record, other_value)
       record.errors.add(attribute, :incoherent, :field=>I18n.t('general.'+ field.to_s)) unless same_period(period, other_period)
     end
    
  end


  protected

  def same_period(p1, p2)
    p1.id == p2.id rescue false
  end

  def find_period(record, value)
    raise 'Le modèle doit répondre à la méthode period' unless record.respond_to?(:period)
    record.period(value)
  end


end
