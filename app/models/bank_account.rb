# -*- encoding : utf-8 -*-

require 'strip_arguments'


# Classe représentant les comptes bancaires.
# Les champs sont
#   - bank_name pour le nom de la Banque
#   - number pour le numéro de compte
#   - nickname pour le surnom par exemple compte courant ou compte sur livret.
#
# Un lien est établi entre le compte bancaire et la compta par les callbacks
#   - after_crate appelle la création du compte comptable (create_accounts)
#   - after_update permet de mettre à jour le libellé de ce compte comptable si on
#   change le nickname
#
# Il y a un compte comptable par exercices, ce qui explique qu'il y a has_many :accounts
# Ce lien permet d'accéder aux compta_lines
# 
# La classe VirtualBook permet de générer un Livre de banque virtuel. La méthode 
# #virtual_book crée cette classe et retourne un VirtualBook. VirtualBook hérite de Book et 
# inclut donc les modules Sold et Graphic
#
#
class BankAccount < ActiveRecord::Base  
  include Utilities::Sold
 

  belongs_to :organism
  belongs_to :sector
  has_many :check_deposits
  has_many :bank_extracts
  
  # un compte bancaire a un compte comptable par exercice
  has_many :accounts, :as=> :accountable
  has_many :compta_lines, :through=>:accounts
  
  has_one :export_pdf, as: :exportable
  
  # extrait les lignes comptables entre deux date et les restitue par ordre de date
  # scope :extract_lines, lambda {|from_date, to_date| compta_lines.joins(:writing).where('writings.date >= ? AND writings.date <= ?', from_date, to_date).order('writings.date') }


  attr_accessible :number, :bank_name, :comment, :nickname, :sector_id

  strip_before_validation :number, :bank_name, :comment

  validates :number,
    :presence=>true,
    :uniqueness=>{:scope=>[:organism_id, :bank_name]},
    :format=>{with:NAME_REGEX},
    :length=>{within:NAME_LENGTH_LIMITS}
  validates :bank_name, :nickname , presence: true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :organism_id, :sector_id, presence:true
  
 
  after_create :create_accounts, :if=>lambda {organism.periods.opened.any? }
  after_update :change_account_title, :if=> lambda {nickname_changed? }
  

 # renvoie le premier (mais en fait l'unique) compte comptable correspondant 
 # à ce compte banciare pour un exercice donné
  def current_account(period)
   accounts.where('period_id = ?', period.id).first
 end

 # renvoie le solde du compte bancaire à une date donnée et pour :debit ou :credit
 # arguments à fournir : la date et le sens (:debit ou :credit).
 # 
 # Renvoie 0 s'il n'y a pas d'écriture ou si un exercice n'existe pas
 # Ce peut être le cas avec un premier exercice commencé en cours d'année
 # quand on est dans l'exerice suivant qui lui est en année pleine.
 def cumulated_at(date, dc)
    p = organism.find_period(date)
    return 0 unless p && acc = current_account(p)
    acc.cumulated_at(date, dc)
 end
 
 # On veut que le solde prenne en compte le solde de l'exercice précédent tant
  # que l'écriture d'à nouveau n'a pas été générée.
  # 
  # On cherche donc l'exercice précédent et on rajoute son solde si cet exercice
  # est ouvert (ce qui veut dire que l'écriture d'A Nouveau n'est pas encore passée).
  # 
  # Lorsque l'exercice a été clos, les écritures d'AN ont été passées et le solde 
  # donne donc la bonne valeur.
  #
  def sold_at(date)
    reponse = super
    p = organism.find_period(date)
    if p && p.previous_period? 
      pp = p.previous_period
      reponse += sold_at(pp.close_date) if pp.open
    end 
    reponse
  end
  
 # créé un nouvel extrait bancaire rempli à partir des informations du précédent
 # le mois courant et solde zéro si c'est le premier
  def new_bank_extract(period)
    previous_be = last_bank_extract(period)
    if previous_be
      begin_date = previous_be.end_date + 1.day
      end_date = begin_date.end_of_month
      begin_sold = previous_be.end_sold
    else
      begin_date = period.start_date
      end_date = begin_date.end_of_month
      begin_sold = 0
    end
    return nil if end_date > period.close_date
    bank_extracts.new(begin_date:begin_date,
                        end_date:end_date,
                        begin_sold:begin_sold)
  end

 # trouve toutes les lignes non pointées et qui ont pour compte comptable le
 # numéro correspondant à ce compte bancaire.
 # 
 # Renvoie un objet de la classe Utilities::NotPointedLines
 #
 def not_pointed_lines
   Utilities::NotPointedLines.new(self)
 end


 # lines est une méthode de la classe NotPointedLines
 #
  def np_lines
    not_pointed_lines.lines
  end
  
  # donne le solde du compte bancaire à une date donnée
#  def sold_at(date)
#    cumulated_at(date, :credit) - cumulated_at(date, :debit)
#  end
  
  
 def first_bank_extract_to_point
   bank_extracts.where('locked = ?', false).order('begin_date ASC').first
 end

 def unpointed_bank_extract?
   bank_extracts.where('locked = ?', false).any?
 end
 
 def virtual_book
   vb = VirtualBook.new
   vb.organism_id = organism.id 
   vb.virtual = self
   vb
 end
 
 # définit son compte racine (utile pour que organism.create_accounts_for puisse 
 # créer les comptes comptables lors de la création d'un nouveau compte bancaire
 def self.compte_racine
   RACINE_BANK
 end


 

protected

 # renvoie le dernier relevé de compte (par date de fin) faisant partie de l'exercice
  def last_bank_extract(period)
     bank_extracts.where('end_date <= ?', period.close_date).order(:end_date).last
  end


 # appelé par le callback after_create, demande à l'organisme de lui créer les 
 # comptes comptables associés (ce qui ne sera fait que pour chacun des exercices
 # ouverts).
 def create_accounts
   logger.debug 'création des comptes liés au compte bancaire' 
   Utilities::PlanComptable.create_financial_accounts(self)
 end

 # quand on change le nickname de la banque il est nécessaire de modifier l'intitulé
 # du compte associé à cette banque.
 def change_account_title
   accounts.each {|acc| acc.update_attribute(:title, nickname)}
 end
 
 

end

