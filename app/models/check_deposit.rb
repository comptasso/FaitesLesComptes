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

   # Le problème ici est que total ne fonctionne pas pour les nouveaux enregistrements
  # car l'id est null et rails fait la somme des enregistrements qui ont check_depositçid == null
  # après une première sauvegarde, les montants sont corrects. D'oû la nécessité de cette
  # méthode set_total pour avoir une variable d'instance total.
  after_initialize :set_total

  validates :bank_account, :deposit_date, :presence=>true
  validates :deposit_date,:bank_account_id, :cant_change=>true  if :bank_extract_line
 

  before_validation :not_empty # une remise chèque vide n'a pas de sens

  before_save :update_lines_if_bank_extract_line

  before_destroy :cant_destroy_when_pointed

 

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
    if bank_extract_line
      logger.warn "Tentative de retirer une ligne à la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
      return @total
    end
    lines.delete(line)
     @total -= line.credit
  end

  
  def pick_check(line)
    if bank_extract_line
      logger.warn "Tentative d'ajouter une ligne à la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
      return @total
    end
    lines <<  line
    @total += line.credit 
  end

  def pick_all_checks
    if bank_extract_line
      logger.warn "Tentative d'appler pick_all_checks sur la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
      return @total
    end
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

  private

  def cant_destroy_when_pointed
    if bank_extract_line
    logger.warn "Tentative de détruire la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
    return false
    end
  end

 # mise à jour des lignes lorsque la remise chèques est pointée
  def update_lines_if_bank_extract_line

    if bank_extract_line
      logger.info "Mise à jour des lignes par before_save de check_deposit #{id} (méthode : update_lines_if_bank_extract_line"
       lines.each { |l| l.update_attributes(:bank_extract_id=>bank_extract_line.bank_extract.id ,:bank_account_id=> bank_account_id)  }
    end
     
  end

  
end
