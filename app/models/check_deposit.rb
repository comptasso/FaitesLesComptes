# coding: utf-8

# Le modèle CheckDeposit correspond à une remise de chèques. La logique est de 
# pouvoir préparer une remise de chèque à partir d'une banque (obligation du bank_account)
# et de remplir cette remise avec les lines (qui sont des chèques à encaisser, ce qui correspond
# au scope non_depose de Line. 
# On peut ensuite ajouter ou retirer des chèques d'une remise. 
# Après dépôt à la banque, le relevé bancaire servira à valider la remise 
# qui ne devra plus pouvoir être modifiée. 
# De même le pointage sur le relevé permettra de remplir l'indicateur bank_account_id 
# des lignes correspondantes. 
#
#


class CheckDeposit < ActiveRecord::Base
  has_many :lines, dependent: :nullify
  belongs_to :bank_account
  # c'est la présence de bank_extract_line qui indique que le check_deposit à été pointé et ne peut plus être modifié
  has_one :bank_extract_line

  attr_reader :total

  validates :bank_account, :presence=>true

  before_validation :not_empty # une remise chèque vide n'a pas de sens

  # Le problème ici est que total ne fonctionne pas pour les nouveaux enregistrements
  # car l'id est null et rails fait la somme des enregistrements qui ont check_depositçid == null
  # après une première sauvegarde, les montants sont corrects. D'oû la nécessité de cette 
  # méthode set_total pour avoir une variable d'instance total.
  after_initialize :set_total
 

  def self.total_to_pick(organism)
    organism.lines.non_depose.sum(:credit)
  end

  def self.nb_to_pick(organism)
    organism.lines.non_depose.count
  end


  def self.lines_to_pick(organism)
    organism.lines.non_depose
  end

  def remove_check(line)
    lines.delete(line)
     @total -= line.credit
  end

  
  def pick_check(line)
    lines <<  line
    @total += line.credit 
  end

  def pick_all_checks
    lines << self.bank_account.organism.lines.non_depose.all
    @total += self.bank_account.organism.lines.non_depose.sum(:credit) if new_record?
  end

  private

  def not_empty
       self.errors[:base] <<  'Il doit y avoir au moins un chèque dans une remise' unless @total > 0
  end

  def set_total
    @total = new_record? ? 0 : lines.sum(:credit)
  end

  
end
