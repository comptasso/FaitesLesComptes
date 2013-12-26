require 'list_months'

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
  has_many :writings, :through=>:mask
   
  validates :day, :mask_id, :title, presence:true
  
  validate :mask_complete?
  
  
  def nb_late_writings
    month_year_to_write.size
  end
  
  # late indique s'il y a des écritures à passer
  def late?
    nb_late_writings > 0
  end
  
  # retourne une collection de MonthYear pour lesquelles l'écriture n'a pas encore 
  # été passée alors qu'elle le devrait
  # 
  # A partir de la date de la dernière écriture passée et de la dernière écriture
  # à passer 
  # 
  def month_year_to_write
    last_to_pass = to_write_this_month? ? subscription_date : subscription_date << 1 
    lwd = last_writing_date
    ListMonths.new(lwd.beginning_of_month, last_to_pass.beginning_of_month)
  end
  
  # Passe les écritures
  def pass_writings
    return unless mask_complete?  # on ne peut passer d'écriture si le masque est incomplet
    return unless late? # pas d'écriture à passer
    month_year_to_write.each {|my| writer.write(my)}
  end
  
  # TODO gérer le end_date car pour l'instant ne le prend pas du tout en compte
  
  
  protected
  
  # date de la dernière écriture pour cet abonnement
  def last_writing_date
    mask.writings.last.date
  end
   
  # calcule la date à laquelle l'écriture doit être passée pour le mois en cours
  # si le mois ne comprent pas assez de jours, recalcule une bonne date pour le mois
  def subscription_date
    d = Date.today.beginning_of_month + (day-1).days # cas général
    d = d.months_ago(1).end_of_month if d.month > Date.today.month # cas où on a changé de mois
    # par exemple on est dans un mois court (février) et le day est à 31
    d
  end
  
  # une souscription ne peut être valide que si le masque est complet
  # donc attention à la modification du masque après coup
  def mask_complete?
    errors.add(:base, :mask_incomplet) unless mask.complete? 
  end
  
  
  def writer
    @writer ||= Utilities::Writer.new(self)
  end
  
  
  # définit si l'écriture devrait être écrite pour le mois en cours
  def to_write_this_month?
    subscription_date.today? || subscription_date.past?
  end
  
  
  
  
end
