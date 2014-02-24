require 'month_year'
require 'strip_arguments'

# Modèle destiné à gérer les abonnements. 
# 
# Les champs utiles sont title pour lui donner un titre,
# end_date : pour indiquer jusqu'à quelle date il faut passer l'abonnement,
# laisser ce champ vide indique un abonnement permanent.
# 
# Seuls les abonnements mensuels sont gérés.
# 
# day est le jour du mois; 31 permet d'indiquer le dernier jour du mois.
# Pour les mois plus courts, un jour incorrect sera corrigé. 
# 
# L'abonnement appartient à un mask_id qui a une relation has_one. 
# 
# Tous les arguments sont obligatoires sauf end_date.
# L'organisme a les abonnements au travers des masques
#
class Subscription < ActiveRecord::Base
    
  attr_accessible :day, :end_date, :mask_id, :title, :permanent
  
  belongs_to :mask
  has_many :writings, :through=>:mask
   
  validates :day, :mask_id, :title, presence:true
  validates :title, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  
  validate :mask_complete?
    
  strip_before_validation :title
  
  before_validation :prepare_params
  
  
  def nb_late_writings
    mys  = month_year_to_write
    mys.end - mys.begin + 1 
  end
  
  # late indique s'il y a des écritures à passer
  def late?
    nb_late_writings > 0
  end
  
  # renvoie le premier MonthYear à écrire s'il faut en écrire
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
    MonthYear.from_date(last_writing_date).succ..MonthYear.from_date(last_to_pass)
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
    d >= to_pass ? to_pass : to_pass << 1  
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
  
  # mais le end_date à nil si l'abonnement est permanent, sinon ajuste le end_date
  # pour le mettre au jour indiqué par 
  def prepare_params
    if permanent
      self.end_date =  nil
    else
      self.end_date = end_date.beginning_of_month + (day-1) 
    end
  end
  
  
  
  
end
