# -*- encoding : utf-8 -*-

# == Schema Information
# Schema version: 20110515121214
#
# Table name: periods
#
#  id                 :integer         not null, primary key
#  start_date         :date
#  close_date         :date
#  organism_id       :integer
#  open               :boolean         default(TRUE)
#  created_at         :datetime
#  updated_at         :datetime
#  first_active_month :integer         default(0), not null
#
#
#
# == Objectif du modèle Period
# Period correspond à un exercice. Les règles sont donc les suivantes :
# - le premier exercice créé peut avoir une durée de moins de 12 mois
# on demande donc la date de début (qui peut être n'importe quoi (mais on
# va fixer un début de mois et la date de fin qui va être une fin de mois
# à distance max de deux ans
# OK un exercice créé est automatiquement le suivant du dernier exercice.
# Cela impose sa date de début et une valeur par défaut de 12 mois pour la date de
# fin.
# OK un exercice clos ne peut être réouvert
# OK il ne peut y avoir que deux exercices ouverts à la fois.
#
# OK la création d'un exercice doit enchainer sur la création des journaux
# TODO faire les oéprations de clôture.
# - la cloture d'un exercice doit être précédée des opérations de cloture.
# OK la date de cloture doit forcément être postérieure à la date d'ouverture
#
#
# le champ first_active_month sert à identifier le premier mois ouvert
# lorsqu'on ferme un mois, tous les journaux correspondants à ce mois sont
# fermés (ce qui valide autmatiquement les écritures qui appartiennent à ces journaux.
# Puis first_active_month est incrémenté.
# TODO mettre ceci dans une transaction




class Period < ActiveRecord::Base

  # Les classes ...validator sont des classes spécifiques de validator pour les exercices

  # Valide que le start_date est le lendemain du close date de l'exercice précédent
  class ContiguousValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "ne peut avoir un trou dans les dates #{record.previous_period.close_date}" if record.previous_period && record.previous_period.close_date != (value - 1.day)
    end
  end

  # Valide que le close_date est bien postérieur au start_date
  class ChronoValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "la date de cloture doit être postérieure à l'ouverture" if value < record.start_date
    end
  end

 
  belongs_to :organism
  
  validates :organism_id, :presence=>true

# TODO revoir les validations
  validates :close_date, :presence=>true,:chrono=>true
  validates :start_date, :presence=>true,:contiguous => true


  # TODO changer le update should not reopen en utilisant un des validate
  before_update :fix_days, :cant_change_start_date, :should_not_reopen
  before_create :should_not_have_more_than_two_open_periods, :fix_days
  before_save :should_not_exceed_24_months, 
    :cant_change_close_date_if_next_period
 

  # TODO voir la gestion des effacer dans les vues et dans le modèle.

  # TODO mettre dans la migration que start_date et close_date sont obligatoires
 
  # Trouve l'exercice précédent
  def previous_period
    Period.first(:conditions=>['organism_id = ? AND close_date < ?', self.organism_id, self.start_date],
      :order=>'close_date DESC')
  end
  # indique s'il y a un exercice précédent
  def previous_period?
    previous_period ? true : false
  end


  # trouve l'exercice suivant
  def next_period
    Period.first(:conditions=>['organism_id = ? AND start_date > ?', self.organism_id, self.close_date],
      :order=>'start_date DESC')
  end

  # indique s'il y a un exercice suivant
  def next_period?
    next_period ? true : false
  end

  # indique si l'exercice est clos
  def is_closed?
    self.open ? false : true
  end


 
  # TODO à revoir avec les fonctions de type distance in ...
  def nb_months
    first_date=[self.close_date, self.start_date].min.beginning_of_month
    last_date=[self.close_date, self.start_date].max.beginning_of_month
    i=0
    while first_date < last_date
      i+=1
      first_date=first_date.months_since(1)
    end
    return i+1
  end

  # renvoie le nombre de jour d'un mois donné de l'exercice
  # mois period est un entier démarrant à 0
  def nb_jour_mois(mois_period)
    self.start_date.months_since(mois_period).end_of_month.day
  end

 # retourne une liste des mois de l'exercice localisée par exemple janvier février,...
  def list_months
    self.nb_months.times.map {|m| I18n::l self.start_date.months_since(m), :format=>'%B'}
  end

  # retourne une liste des mois de l'ex localisée sous forme fév. 11 mar. 11 ...
  def list_months_year
    self.nb_months.times.map {|m| I18n::l self.start_date.months_since(m), :format=>'%b %y'}
  end



  # permet d'indiquer l'exercice sous la forme d'une chaine de caractère
  # du type Exercice 2011 si period correspond à une année pleine
  # ou de Mars 2011 à Février 2012 si c'est à cheval sur l'année civile.
  def exercice
    r=''
    if self.start_date==self.start_date.beginning_of_year
      r= 'Exercice ' << self.start_date.year.to_s
    else
      r= '- de ' << (I18n::l self.start_date, :format=>:short_month_year)
      r << ' à ' << (I18n::l self.close_date, :format=>:short_month_year)
    end
    r
  end
  
   # renvoie le mois le plus adapté pour un exercice
  # si la date du jour est au sein de l'exercice, renvoie le mois correspondant
  # si la date du jour est avant l'exercice, renvoie le premier mois
  # si elle est après, renvoie le dernier mois
  #
  def guess_month(date=Date.today)
    return 0 if date < self.start_date
    return self.nb_months - 1 if date > self.close_date
    return current_month(date)
  end



  # fournit un tableau donnant les recettes mensuelles avec cumul
  def stat_income_year(destination_id=0)
    s=[]
    if destination_id==0
   self.nb_months.times.collect {|m| s << self.stat_income(m)}
    else
self.nb_months.times.collect {|m| s << self.stat_income_filtered(m, destination_id)}
    end
   s << s.sum
  end

   # fournit un tableau donnant les dépenses mensuelles avec cumul mais avec filtre sur la destination
  def stat_outcome_year(destination_id=0)
    s=[]
     if destination_id==0
     self.nb_months.times.collect {|m| s << self.stat_outcome(m)}
    else
     self.nb_months.times.collect {|m| s << self.stat_outcome_filtered(m,destination_id)}
    end
    s << s.sum
  end

  

  # donne le montant des recettes pour un mois donné de l'exercice
  def stat_income(mois)
    arr=self.organism.lines.period_month(self, mois).all :joins=>:nature, :conditions=>{'natures'=>{'income_outcome'=>true}}
    arr.sum(&:credit)-arr.sum(&:debit)
  end

# donne le montant des dépenses pour un mois donné de l'exercice
  def stat_outcome(mois)
    arr=self.organism.lines.period_month(self, mois).all :joins=>:nature, :conditions=>{'natures'=>{'income_outcome'=>false}}
    arr.sum(&:credit)-arr.sum(&:debit)
  end

  def stat_income_filtered(mois, filter)
    arr=self.organism.lines.period_month(self, mois).all :joins=>[:nature,:destination],
      :conditions=>{'natures'=>{'income_outcome'=>true}, 'destinations'=>{'id'=>filter}}
    arr.sum(&:credit)-arr.sum(&:debit)
  end

  def stat_outcome_filtered(mois, filter)
    arr=self.organism.lines.period_month(self, mois).all :joins=>[:nature,:destination],
      :conditions=>{'natures'=>{'income_outcome'=>false}, 'destinations'=>{'id'=>filter}}
    arr.sum(&:credit)-arr.sum(&:debit)
  end

 

#  # report_entries écrit dans l'exercice suivant l'écriture d'ouverture de
#  # l'exercice - report de tous les comptes de bilan et solde dans le compte de
#  # report à nouveau.
#  #
#  def report_entries
#    # on prend tous les comptes commençant par 1 à 5
#    begin
#      as=[]
#      5.times do |i|  # TODO il doit y avoir plus élégant
#        search=i.to_s+'%'
#        as << self.accounts.order(:acc_number).where('acc_number LIKE ?', search).all
#        as.flatten!
#      end
#      # préparation des éléments pour créer l'écriture
#
#      np=self.next_period
#
#
#      odj=np.journals.where('abbreviation=? AND jmonth= ?', 'OD', 0).first
#      date=np.start_date
#      e=Entry.new(:entry_date=>date, :journal_id=>odj.id,
#        :narration=>"Ouverture de l'exercice")
#      # l'entry existe, on créé les lignes
#      as.each do |a| #a pour account
#        if a.solde.abs  > 0 # pour chaque compte dont le solde est à zero
#          # il faut que le compte existe
#          npa=np.accounts.find_by_acc_number(a.acc_number)
#          if npa.nil? # ou le créer
#            npa=np.accounts.create!(:acc_number=>a.acc_number,:name=>a.name, :comment=>a.comment, :regroupement=>a.regroupement)
#          end
#          e.lines.build(:account_id=>npa.id, :amount=>a.solde.abs , :dc=> a.solde > 0 ? true : false )
#        end
#      end # on a fait tous les reports
#
#      # il reste à faire l'écriture du report proprement dit (autrement dit d'équilibrer l'écriture
#      report= e.total_debit - e.total_credit # on calcule le solde
#      if report != 0
#        report_account = np.accounts.where('acc_number=?', '12').first
#        e.lines.build(:account_id=>report_account.id, :amount=>report , :dc=> true )
#      end
#      e.save
#      return e.lines.size
#    rescue
#      return 0
#    end
#
#  end


  


  # Les conditions pour qu'un exercice puisse être fermé sont :
  # qu'il soit ouvert
  # que tous ses journaux soit fermés
  # que l'exercice précédent soit fermé
#  def is_lockable?
#    self.errors.add(:lock, 'Exercice déja fermé') unless self.open
#    # tous les journaux doivent être fermés
#    self.errors.add(:lock, 'Tous les journaux ne sont pas fermés; ') if self.journals.where('open=?', true).any?
#    # l'exercice précédent, s'il existe, doit être ferme
#    self.errors.add(:lock, "L'exercice précédent n'est pas fermé; ") if self.previous_period && self.previous_period.open
#    # il faut un exercice suivant
#    np=self.next_period
#    self.errors.add(:lock, "Pas d'exercice suivant; ") if np.nil?
#    return false if self.errors[:lock].any?
#    # il faut un compte pour le report du résultat
#    self.errors.add(:lock, "Pas de compte de report à nouveau") if np.accounts.where('acc_number=?', '12').first.nil?
#    # il faut un journal d'OD
#    jod=np.journals.where('jmonth=?',0).where('abbreviation=?', 'OD').first
#    self.errors.add(:lock, "Pas de journal d'OD dans l'exercice suivant; ") if jod.nil?
#    return false if self.errors[:lock].any?
#    # qui doit être ouvert
#    # TODO il faut interdire de fermer un mois si l'exercice précédent n'est pas clos
#    self.errors.add(:lock, "Le journal d'OD de l'exercice suivant est fermé; ") unless jod.open
#    self.errors[:lock].any? ? false : true
#
#  end

 

    protected
  # renvoie le mois de l'exercice correspondant à une date qui est dans les limites de l'exercice
  def current_month(date=Date.today)
    raise 'date is not inside the period limits' if date < self.start_date || date > self.close_date
    d=self.start_date
    mois=0
    while date >= d
      d=d.months_since(1)
      mois +=1
    end
    return mois-1
  end




  # on ne peut jamais changer la date de début d'un exercice créé.
  # soit c'est le premier et la date de début a été fixée lors de la création
  # de la organism
  # soit ce n'est pas le premier et il est lié à l'exercice précédent
  # TODO revoir ces deux fonctions.
  def cant_change_start_date
    if self.changed_attributes['start_date'] 
      self.errors.add(:start_date, "Impossible de changer la date d'ouvrture d'un exercice suivant")
      return false 
    end
  end

  # on ne peut pas changer la date de clôture si l'exercice suivant a déja été créé
  # TODO voir si on ne pourrait pas assouplir la règle
  def cant_change_close_date_if_next_period
    if self.changed_attributes['close_date'] && next_period
      self.errors.add(:close_date, 'Impossible de changer la date de cloture avec un exercice suivant')
      return false 
    end
  end

  # TODO à transformer en validate (comme pour les autres modèles)
  def should_not_reopen
    if self.changed_attributes["open"] == false
      self.errors.add(:open, 'Impossible de réouvrir un exercice clos')
      return false 
    end
  end

  def should_not_have_more_than_two_open_periods
    if self.organism.nb_open_periods >= 2
      self.errors.add(:base, "Impossible d'avoir plus de deux exercices ouverts")
      return false
    end
     
  end

  def should_not_exceed_24_months
    if self.close_date - self.start_date > 731
      self.errors.add(:close_date, 'un exercice ne peut avoir plus de deux ans')
      return false
    end
  end

  def fix_days
    self.start_date=self.start_date.beginning_of_month
    self.close_date=self.close_date.end_of_month
  end


 
end
