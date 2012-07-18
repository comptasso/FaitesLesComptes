# coding: utf-8

# La classe OptionsForNatureSelect et son pendant OptionsForAccountSelect
# sert à fournir au select des natures les différentes données nécessaires
# Le but est d'avoir un Select avec par exemple
# Dépenses (en tête du Groupe)
#   - courses
#    - loyer
# Recettes
#   -salaire
#   - poker
#
#   La classe est créée avec trois argument : titre, method et period
#   method est un symbole de méthode qui permet de construire les options à
#   partir de period (ici period.recettes_natures par ex)
#   title donnera le titre du groupe
#   options donnera la liste des objets (ici des natures)
#
#
#   On peut alors créer la collection nécessaire pour le formulaire.
#   Par exemple, une collection de deux groupes d'option pourrait être
#   la_collection = [OptionsForAssociationSelect.new('Recettes', :recettes_natures, period),
#   OptionsForAssociationSelect.new('Dépenses', :recettes_natures, period)]
#
#   et dans le form on utilise de le manière suivante :
#   <%= f.association :natures, :label=> 'Natures associées', input_html: {size: 10, multiple:true},
#                :collection => la_collection, :as => :grouped_select,
#                :group_method => :options,
#                :group_label_method=> :title,
#                :label_method=> :name, :value_method=> :id %>
#
#  Ces deux dernières méthodes name et id doivent évidemment exister
#  pour les objets concernés
#
class OptionsForAssociationSelect
  attr_reader:title

  def initialize(titre, method, period)
    @title=titre
    @object=period
    @method=method
  end

  def options
    @object.send(@method)
  end

end
