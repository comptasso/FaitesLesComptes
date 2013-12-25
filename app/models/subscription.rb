# Modèle destiné à gérer les abonnements. 
# 
# Les champs utiles sont title pour lui donner un titre,
# end_date : pour indiquer jusqu'à quelle date il faut passer l'abonnement,
# laisser vide ce champ indique un abonnement sans limite.
# 
# Par défaut, la périodicité est mensuelle. A voir ultérieurement si des 
# besoins complémentaires apparaissent. 
# 
# day est le jour du mois; 31 permet d'indiquer le dernier jour du mois.
# Pour les mois, plus courts, un jour incorrect sera corrigé. 
# 
# L'abonnement appartient à un mask_id qui a une relation has_one. 
# 
# Tous les arguments sont obligatoires sauf end_date.
# L'organisme a les abonnements au travers des masques
#
class Subscription < ActiveRecord::Base
  attr_accessible :day, :end_date, :mask_id, :title
  
  belongs_to :mask
end
