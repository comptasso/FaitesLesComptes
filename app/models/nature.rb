# -*- encoding : utf-8 -*-

# La classe Nature permet une indirection entre les comptes d'un exercice
# et le type de dépenses ou de recettes correspondant
#
# Le choix de relier Nature aux Account d'une Period, permet de
# modifier les natures d'un exercice à l'autre (ainsi que le rattachement aux
# comptes).
#
# Les natures sont reliées aux livres, ce qui permet de limiter les natures
# disponibles lorsqu'on écrit dans un livre aux seules natures de ce livre
# (et donc incidemment de limiter les comptes accessibles pour un livre).
#
#
class Nature < ActiveRecord::Base

  acts_as_tenant
  belongs_to :period
  belongs_to :account
  belongs_to :book

  has_many :compta_lines
  has_many :writings, through: :compta_lines

  acts_as_list :scope=>[:period_id, :book_id], add_new_at:'perso'

  strip_before_validation :name, :comment

  validates :period_id, :book_id, :presence=>true
  validates :account_id, :fit_type=>true
  validates :name, presence: true,
    :uniqueness=>{ :scope=>[:book_id, :period_id] },
    :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX},
    :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true


  scope :recettes,
    -> {includes(:book).where('books.type = ?', 'IncomeBook').
      order(:position).references(:books)}
  scope :depenses,
    -> {includes(:book).where('books.type = ?', 'OutcomeBook').
      order(:position).references(:books)}
  scope :without_account, -> {where('account_id IS NULL')}

  scope :within_period, lambda { |per| where('period_id = ?' , per.id)}

  before_destroy :ensure_no_lines
  before_destroy :remove_from_list  #est défini dans le plugin acts_as_list
  after_create :fix_position
  # after_update obligatoire car mask a des validations qui vont chercher
  # la nature dans la base
  after_update :update_masks, if: :name_changed?


  # Attention, il existe aussi un NatureObserver qui a des actions after_save

  # TODO probablement inutile maintenant
  # Stat_with_cumul fournit un tableau comportant le total des lignes
  # pour la nature pour chaque mois plus un cumul de ce montant
  # en dernière position
  # Fait appel selon le cas à deux méthodes protected stat ou stat_filtered.
#  def stat_with_cumul(destination_id = 0)
#    s = (destination_id == 0) ? self.stat : self.stat_filtered(destination_id)
#    s << s.sum.round(2) # rajoute le total en dernière colonne
#  end

  # Stat crée un tableau donnant les montants totaux de la nature pour chacun
  # des mois de la période pour toutes les destinations confondues
  # TODO probablement inutile maintenant
#  def stat
#    period.list_months.map do |m|
#      compta_lines.mois_with_writings(m).sum('credit-debit').to_f.round(2)
#    end
#  end

  def self.statistics(period, destination_ids = [0])
    res = query_monthly_datas(period, destination_ids)
    mise_en_forme(res, period)
  end



  def in_out_to_s
    book.title
  end

  # méthode provisoire pour tester la cohérence des natures
  def self.check_coherence
    coherent = true
    db = Organism.first.database_name
    Nature.find_each do |n|
      next unless n.account
      sector1id = n.account.sector.id if n.account.sector
      sector2id = n.book.sector.id

      if sector1id != sector2id
        puts "#{db} : #{n.id} reliée à #{sector1id} et #{sector2id}"
        Rails.logger.warn "#{db} : #{n.id} reliée à #{sector1id} et #{sector2id}"
        coherent = n.change_book_to_fit_account

      end
    end
    coherent ? nil : db
  end

  #
  def change_book_to_fit_account
    return false if compta_lines.any?
    new_sector = account.sector
    new_book = Book.where('type = ? AND sector_id = ?', book.type, new_sector.id).first
    self.book_id = new_book.id
    save!
    puts "modification de la nature #{id}"
    return true
  end


  protected


  # Extrait de nature les champs book_id, position, id, name (nname)
  # pour chaque nature de l'exercice.
  # mony est un champ de la forme MM-YYYY, valeur donne le total du mois
  #
  # On récupère alors un tableau de Natures.
  # On peut filter sur le champ destination qui peut comprendre
  #
  def self.query_monthly_datas(period, destination_ids = [0])
    if destination_ids == [0]
      dids = nil
    else
      dids = destination_ids.join(', ')
    end

    inrequest = "AND compta_lines.destination_id IN (#{dids})"

    sql = <<-hdoc
SELECT natures.id, position, name, mony, valeur FROM

natures,
(SELECT
     natures.id AS nid, natures.name AS nname,
     SUM(compta_lines.credit) - SUM(compta_lines.debit) AS valeur,
     to_char(writings.date, 'MM-YYYY') AS mony
FROM
     writings,
     compta_lines,
     natures
WHERE
     writings.id = compta_lines.writing_id AND
     compta_lines.nature_id = natures.id  #{dids ? inrequest : nil}
GROUP BY nid, mony) AS subt

WHERE natures.period_id = #{period.id} AND natures.id = subt.nid

ORDER BY position


hdoc

    Nature.find_by_sql(sql)

    # ici on a donc une table d'enregistrement Nature avec un nombre
    # d'enregistrement égale au nombre de mois avec une valeur
  end


  def self.mise_en_forme(res, period)

    lms= period.list_months
    period.natures.joins(:book).order('type ASC', 'position ASC').collect do |n|
      ligne =
      lms.collect do |lm|
        val = res.select {|r| r.id == n.id && r.mony == lm.to_s}
        val.empty? ? 0.0 : val.first.valeur
      end
      ligne << ligne.inject(:+) # fait le total
      ligne.unshift(n.name)

    end

  end


  # FIXME Le plugin acts_as_list fait un appel à update position, ce qui crée du
  # coup un appel à cette méthode, même pour un nouvel enregistrement.
  def update_masks
    period.organism.masks.filtered_by_name(name_was).each do |m|
      m.update_attributes(nature_name:name)
    end
  end



  # appelé par after_create pour définir la position
  def fix_position
    insert_at(find_right_position)
  end



  # Stat_filtered crée un tableau donnant les montants totaux de la nature pour chacun des mois de la période
  # pour une destination donnée
  def stat_filtered(destination_id)
    period.list_months.map do |m|
      compta_lines.mois_with_writings(m).where('destination_id=?', destination_id).sum('credit-debit').to_f.round(2)
    end
  end

  private

  def ensure_no_lines
    if compta_lines.empty?
      return true
    else
      errors.add(:base, 'Des écritures font référence à cette nature')
      return false
    end
  end

  # hack utilisé pour éviter que acts_as_list gère la position d'un new
  # record.
  # Dans la déclaration plus haut de acts_as_list, on a indiqué que la gestion
  # des nouveaux items se faisait par cette méthode, laquelle ne fait rien
  # car on gère autrement les changements de position.
  # Il semble difficile de faire autrement par défaut de maîtrise de l'ordre
  # des after_save introduit par le gem acts_as_list.
  def add_to_list_perso

  end

  # Par défaut, on cherche à regrouper les natures par numéro de compte associé
  # et on met la nouvelle nature en début du groupe.
  #
  # Donne la position par défaut pour une nouvelle nature basée sur
  # l'ordre des numéros de comptes.
  #
  # Si une (ou des) natures sont déjà connectées à ce compte, alors
  # elle se place en dernière position
  #
  # S'il n'y a pas de nature correspondant à ce compte, cherche la nature ayant
  # un numéro de compte correspondant. On ne parle évidemment que des natures
  # qui relèvent du même livre et du même exercice.
  def find_right_position

    return (self.send(:bottom_position_in_list) +1) unless account_id
    acc =  Account.find(account_id)
    return (self.send(:bottom_position_in_list) +1) unless acc # cas théorique impossible sauf dans les tests


    n = Nature.includes(:account).
      where('natures.period_id = ? AND book_id = ? AND accounts.number >= ? AND natures.id != ?',
      period_id, book_id, acc.number, id).
      order('accounts.number', 'position').first

    n ? n.position : (self.send(:bottom_position_in_list) +1)


  end

end
