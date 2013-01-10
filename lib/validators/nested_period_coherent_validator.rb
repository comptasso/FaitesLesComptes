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
class NestedPeriodCoherentValidator < ActiveModel::EachValidator

  # pour lire l'option
  def initialize(options)
    @nested = options[:nested]
    @fields = options[:fields]
    super
  end

  # Trouve la period puis pour chacun
  # des champs de l'option :fields, appelle
  # la méthode check_field
  #
  def validate_each(record, attribute, value)
      period = find_period(record)
      # flatten pour pouvoir accepter dans l'option :fields un seul élément ou un Array
     [@fields].flatten.each {|field| check_field(period, record, attribute, field)} if value
     # le test ne s'effectue que s'il y a une valeur; utiliser presence:true pour contraindre à la
     # présence de cette valeur
  end

  # check_field vérifie et ajoute une erreur pour chacun des nested_attributes.
  #
  # Par exemple pour compta_lines si le validator a été appelé avec :nested=>:compta_lines
  #
  def check_field(period, record, attribute, field)
    
    raise "#{record} ne répond pas à #{@nested}" unless record.respond_to?(@nested)
    if period
    record.send(@nested).each do |cl|
      cl_field = cl.send(field)
      record.errors.add(attribute, :incoherent, :field=>I18n.t('general.'+ field.to_s)) if (cl_field && (cl_field.period.id != period.id))
    end
    else
      record.errors.add(attribute, :no_period)
    end
  end

  protected

  def find_period(record)
    raise 'Le modèle doit répondre à la méthode period' unless record.respond_to?(:period)
    record.period 
  end


end
