# coding: utf-8

# La tables books représente les livres.
# Une sous classe IncomeOutcomeBook représente les livres de recettes et de dépénses
# chacun au travers de leur classe dérivée (IncomeBook et OutcomeBook)
#
# Les journaux sont aussi représentés par la classe Book
#
# Il y a un journal d'OD et un d'AN systématiquement créé pour chaque organisme
#
class Book < ActiveRecord::Base

  include Utilities::JcGraphic

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold

  acts_as_tenant
  # attr_accessible :title, :description, :abbreviation

  belongs_to :organism
  has_many :writings, :dependent=>:delete_all
  has_many :compta_lines, :through=>:writings

  # utilisé pour les delayed_jobs
  has_one :export_pdf, as: :exportable

  scope :in_outs, -> {where(:type=> ['IncomeBook', 'OutcomeBook'])}

  strip_before_validation :title, :description, :abbreviation

  validates :title, presence: true, uniqueness:{scope: :organism_id},
    :format=>{:with=>NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :abbreviation, presence: true, :format=>{:with=>/\A[A-Z]{1}[A-Z0-9]{1,3}\Z/}
  validates_uniqueness_of :abbreviation, scope: :organism_id
  validates :description, :format=>{:with=>NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :organism_id, presence:true

  def book_type
    self.class.name
  end

  # TODO specs de cette méthode à faire
  def cumulated_at(date, dc)
    p = organism.find_period(date)
    val = p ? writings.joins(:compta_lines).period(p).where('date <= ?', date).sum(dc) : 0
    val.to_f # nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
    # problèmes de calcul
  end

  # astuces trouvéexs dans le site suivant
  # http://www.alexreisner.com/code/single-table-inheritance-in-rails
  #
  # TODO voir les méthodes adaptées de Rails. Il semble qu'elles existent
  # Le but de cette méthode est de redéfinir la méthode model_name qui est utilisée
  # pour la génération des path. Ainsi un IncomeBook répond quand même Book à la méthode model_name
  # et la construction des path reste correcte.
  def self.inherited(child)
    child.instance_eval do
      def model_name
        Book.model_name
      end
    end
    super
  end

  # méthode en cours de développement pour l'édition du csv
  # TODO il faudra filtrer les compta_lines sur une période bien déterminée
  # voir également pour faire des sous_totaux par mois
  # TODO voir si on conserve car en fait on utilise plus les fonctionnalités
  # des Extract et des Editions
  def to_csv(options = {col_sep:"\t"})
    CSV.generate(options) do |csv|
      csv << %w(Date Pièce Réf Libellé Compte Intitulé Débit Crédit)
      compta_lines.each do |cl|
        csv << [cl.writing.date, cl.writing.piece_number, cl.writing.id, cl.writing.ref, cl.writing.narration,
          cl.account.number, cl.account.title, cl.debit, cl.credit]
      end
      #        csv << ['Totaux', ''] + total_balance.collect {|val| reformat(val)}
    end
  end


  # mise en place des fonctions qui permettent de construire les graphiques avec
  # très peu d'appel à la base de données
  # récupère les soldes pour une caisse pour un exercice
  #
  # Renvoie un hash selon le format suivant
  # {"09-2013"=>"-24.00", "01-2013"=>"-75.00", "08-2013"=>"-50.00"}
  #
  # Les mois où il n'y a pas de valeur ne renvoient rien.
  # Il faut donc ensuite faire un mapping ce qui est fait par la méthode
  # build_datas de Utilities::Graphic
  #
  def query_monthly_datas(period)


    sql = <<-hdoc
 SELECT
     to_char(writings.date, 'MM-YYYY') AS mony,

     SUM(compta_lines.credit) - SUM(compta_lines.debit) AS valeur
 FROM

     writings,
     compta_lines
 WHERE

   writings.book_id = #{id} AND
 writings.date >= '#{period.start_date}' AND
 writings.date <= '#{period.close_date}' AND
     compta_lines.writing_id = writings.id AND
 nature_id IS NOT NULL

 GROUP BY mony
    hdoc

    res = VirtualBook.connection.execute( sql.gsub("\n", ''))
    h = Hash.new('0')
    res.each {|r| h[r['mony']]= r["valeur"] }
    h

  end


end
