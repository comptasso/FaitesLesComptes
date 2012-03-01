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

  # La condition est mise ici pour éviter que check_deposit.new soit associée d'emblée
  # à toutes les lignes qui n'ont pas de check_depsoit_id
  # L'objectif est que check_deposit soit capable de donner la somme des chèques en partant de zero
  belongs_to :bank_account
  has_many :lines, dependent: :nullify,
                    conditions: 'check_deposit_id IS NOT NULL',
                    
                    after_remove: :nil_bank_account_id

#  has_many :pending_checks,  class_name: 'Line',
#              dependent: :nullify,
#              conditions: {:bank_account_id => nil,
#                            :payment_mode => 'Chèque',
#                            'credit > 0',
#                            :book_id => [1,2]
#              }
                                          

  # c'est la présence de bank_extract_line qui indique que le check_deposit à été pointé et ne peut plus être modifié
  has_one :bank_extract_line

  validates :bank_account, :deposit_date, :presence=>true
  validates :deposit_date,:bank_account_id, :cant_change=>true  if :bank_extract_line
 

  before_validation :not_empty # une remise chèque vide n'a pas de sens

  after_save :update_lines_if_bank_extract_line, :update_bank_account_id_for_lines

  before_destroy :cant_destroy_when_pointed

  
  def book_ids
    return [1]
    bank_account.organism.books.all.map {|m| m.id}.join(',')
  end
 

  def self.total_to_pick(organism)
    organism.lines.non_depose.sum(:credit)
  end

  def self.nb_to_pick(organism)
    organism.lines.non_depose.count
  end


  def self.lines_to_pick(organism)
    organism.lines.non_depose
  end

 # utilisation de total et non de sum car on ne veut pas avoir une somme par requete sql
 # mais une somme qui prenne effectivement en compte les lignes qui sont dans la 
 # target de l'association has_many
  def total
    total=0
    lines.each {|l| total += l.credit}
    total
  end

  def remove_check(line)
    if bank_extract_line
      logger.warn "Tentative de retirer une ligne à la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
      return total
    end
    lines.delete(line)
    return total
  end

  
  def pick_check(line)
    if bank_extract_line
      logger.warn "Tentative d'ajouter une ligne à la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
      return total
    end
    lines <<  line
    return total
  end

  def pick_all_checks
    if bank_extract_line
      logger.warn "Tentative d'appler pick_all_checks sur la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
      return total
    end
    bank_account.organism.lines.non_depose.all.each {|l| lines << l}
    return total
  end

  private

  def not_empty
       self.errors[:base] <<  'Il doit y avoir au moins un chèque dans une remise' unless total > 0
  end

  
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
       lines.each { |l| l.update_attributes(:bank_extract_id=>bank_extract_line.bank_extract.id)  }
    end
     
  end

  def update_bank_account_id_for_lines
    # puts "nombre de lignes : #{lines.size} -- bank_account_id : #{bank_account.id}"
    lines.each {|l| l.update_attribute(:bank_account_id, bank_account.id)}
  end

#  def fill_bank_account_id(line)
#    line.bank_account_id =bank_account_id
#  end

  def nil_bank_account_id(line)
    line.update_attribute(:bank_account_id, nil)
  end
  
end
