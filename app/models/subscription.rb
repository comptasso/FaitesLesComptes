require 'list_months'
require 'month_year' 

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
  
  def first_to_write
    month_year_to_write.first if late?
  end
  
  # retourne une collection de MonthYear pour lesquelles l'écriture n'a pas encore 
  # été passée alors qu'elle le devrait
  # 
  # A partir de la date de la dernière écriture passée et de la dernière écriture
  # à passer 
  # 
  def month_year_to_write
    lwd = last_writing_date
    # rappel ListMonths renvoie un MonthYear tant que begin_date < end_date
    # il est donc essentiel de se mettre au début du mois pour last_to_pass
    
    ListMonths.new(lwd.beginning_of_month >> 1 , last_to_pass.end_of_month)
  end
  
  # Passe les écritures
  def pass_writings
    return  0 unless mask_complete?  # on ne peut passer d'écriture si le masque est incomplet
    return  0 unless late? # pas d'écriture à passer
    count = 0
    month_year_to_write.each do |my|
      count += 1 if writer.write(subscription_date(my))
    end 
    count
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
  
  # donne la dernière écriture qui devrait être à passer au jour actuel. Donc peut être soit 
  # dans le mois présent, soit dans le mois précédent si le day n'est pas encore
  # atteint, 
  # soit encore sensiblement avant si end_date est dépassé.
  # 
  # Ne s'occupe pas des écritures déjà passées. 
  # 
  # C'est la comparaison de last_writing_date et last_to_pass qui va permettre 
  # de savoir ce qu'il faut passer
  def last_to_pass
    ed = end_date || Date.today
    d = [Date.today, ed].min # on ne dépasse pas le end_date de la subscription s'il existe
    # on trouve le jour où il faut passer l'écriture pour ce mois
    to_pass = subscription_date(MonthYear.from_date(d))
    d >= to_pass ? d : d << 1  
  end
  
  # date de la dernière écriture pour cet abonnement
  # s'il n'y a pas encore d'écritures, renvoie le mois précédent la création
  # du mask pour permettre une écriture pour le mois en cours
  def last_writing_date
    mask.writings.last.date rescue mask.created_at.to_date << 1
  end
   
  # calcule la date à laquelle l'écriture doit être passée pour un MonthYear donné
  # 
  # Si pas d'argument, donne la date pour le mois en cours.
  # si le mois ne comprent pas assez de jours, recalcule une bonne date pour le mois
  def subscription_date(monthyear = MonthYear.from_date(Date.today))
    monthyear.to_date(day)
  end
  
  # une souscription ne peut être valide que si le masque est complet
  # donc attention à la modification du masque après coup
  def mask_complete?
    reponse = mask.complete?
    errors.add(:base, :mask_incomplet) unless reponse
    reponse
  end
  
  
  def writer
    Utilities::Writer.new(self)
  end
  
  
  # définit si l'écriture devrait être écrite pour le mois en cours
  def to_write_this_month?
    subscription_date.today? || subscription_date.past?
  end
  
  
  
  
end