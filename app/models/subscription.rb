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
  include Utilities::PickDateExtension # apporte les méthodes pick_date_for

  # TODO utiliser les trim et les règles de validation pour le titre
  
  attr_accessible :day, :end_date, :mask_id, :title, :permanent
  
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
    lwd = last_writing_date
    ListMonths.new(lwd.beginning_of_month, last_to_pass.beginning_of_month)
  end
  
  # Passe les écritures
  def pass_writings
    return unless mask_complete?  # on ne peut passer d'écriture si le masque est incomplet
    return unless late? # pas d'écriture à passer
    month_year_to_write.each {|my| writer.write(my)}
  end
  
  # méthodes ajoutées pour faciliter la construction du formulaire
  # indique si l'abonnement est permanent
  def permanent
    !end_date
  end
  
  # si on indique que le virement est permanent, alors on efface end_date
  # sinon, on garde end_date ou on le remplit avec la date du jour s'il n'était 
  # pas déjà rempli.
  def permanent=(bool)
    if bool
      end_date = nil
    else
      end_date ||= Date.today
    end
  end
  
  
  protected
  
  # donne la dernière écriture à passer au jour actuel. Donc peut être soit 
  # dans le mois présent, soit dans le mois précédent si le day n'est pas encore
  # atteint, 
  # soit encore sensiblement avant si end_date est dépassé.
  def last_to_pass
    ed = end_date || Date.today
    d = [Date.today, ed].min # on ne dépasse pas le end_date de la subscription s'il existe
    d.day >= subscription_date(d.month).day ? d : d << 1  
  end
  
  # date de la dernière écriture pour cet abonnement
  def last_writing_date
    mask.writings.last.date
  end
   
  # calcule la date à laquelle l'écriture doit être passée pour le mois en cours
  # si le mois ne comprent pas assez de jours, recalcule une bonne date pour le mois
  def subscription_date(month = Date.today.month)
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
