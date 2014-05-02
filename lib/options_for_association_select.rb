# coding: utf-8

# La classe OptionsForAssociationSelect
# sert à fournir au select les différentes données nécessaires
# pour faire des groupes.
# 
# Le but est d'avoir un Select avec par exemple
# Dépenses (en tête du Groupe)
#   - courses
#    - loyer
# Recettes
#   -salaire
#   - poker
#
#   La classe est créée avec trois argument : titre, method et model
#   method est un symbole de méthode qui permet de construire les options à
#   partir du modèle (par exemple period.recettes_natures si le modèle est period
#   et la méthode :recette_natures)
#   title donnera le titre du groupe
#   options donnera des options qui seront utilisées comme argument 
#   de l'appel à la méthode. 
#   
#   Par exemple 
#   OptionsForAssociationSelect.new('Banques', :list_bank_accounts, sector, period)
#   permet se traduit par le titre Banques et 
#   par les éléments collectés par la méthode sector.list_bank_accounts(period)
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

  def initialize(titre, method, model, option=nil)
    @title=titre
    @method=method
    @object=model
    @option = option
  end

  def options
    if @option
      @object.send(@method, @option)
    else
      @object.send(@method)
    end
  end

end
