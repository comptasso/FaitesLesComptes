# coding: utf-8

require 'change_period'

class Compta::PeriodsController < Compta::ApplicationController


  logger.debug 'dans Compta::PeriodsController'
  # ChangePeriod ajoute la méthode change, méthode partagée par les différents PeriodsController
  # Voir le fichier lib/change_period.rb.
  #
  # Change a pour effet de changer d'exercice et de revenir à l'action initiale.
  # Dans le cas où cette action a des paramètres mois et an, change recalcule des
  # nouveaux paramètres adaptés à l'exercice sélectionné.
  #
  include ChangePeriod



 
end
