# coding: utf-8

# Le modèle CheckDeposit correspond à une remise de chèques. La logique est de 
# pouvoir préparer une remise de chèque à partir d'une banque (obligation du bank_account)
# et de remplir cette remise avec les checks (qui sont des chèques à encaisser, ce qui correspond
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
  has_many :checks, class_name: 'Line',
                    dependent: :nullify,
                    conditions: 'credit > 0 and payment_mode = "Chèque" ', # and book_id IN ("#{bids}")',
                    before_remove: :cant_if_pointed, #on ne peut retirer un chèque si la remise de chèque a été pointée avec le compte bancaire
                    after_remove: :nil_bank_account_id,
                    before_add: :cant_if_pointed  do


                 # utilisation de total avec inject et non de sum car on ne veut pas avoir une somme par requete sql
                 # mais une somme qui prenne effectivement en compte les lignes qui sont dans la
                 # target de l'association has_many
                  def total
                    proxy_association.target.inject(0) {|i,l| i += l.credit}
                  end

                  def proprio
                    puts proxy_association.owner
                  end


               end

def self.organism(organism)
   @@organism=organism
end

  def self.bids
    puts @@organism
    raise "Organism n est pas defini et donc on ne peut trouver les livres" unless @@organism
    @@organism.books.select(:id).collect {|m| m.id }
  end

  def define_organism(organism)
    @@organism=organism
  end
       

  # c'est la présence de bank_extract_line qui indique que le check_deposit à été pointé et ne peut plus être modifié
  has_one :bank_extract_line

  validates :bank_account, :deposit_date, :presence=>true
  validates :deposit_date,:bank_account_id, :cant_change=>true  if :bank_extract_line
 

  before_validation :not_empty # une remise chèque vide n'a pas de sens

  after_save :update_checks_if_bank_extract_line, :update_bank_account_id_for_checks

  before_destroy :cant_destroy_when_pointed
  
 
  def self.total_to_pick(organism)
    organism.lines.non_depose.sum(:credit)
  end

  def self.nb_to_pick(organism)
    organism.lines.non_depose.count
  end


  def self.checks_to_pick(organism)
    organism.lines.non_depose
  end


  def pick_all_checks
    bank_account.organism.lines.non_depose.all.each {|l| checks << l}
  end

  private

  def not_empty
       self.errors[:base] <<  'Il doit y avoir au moins un chèque dans une remise' if checks.empty?
  end

  def cant_if_pointed(line)
    if bank_extract_line
      logger.warn "Tentative de retirer une ligne à la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
      raise 'Impossible de retirer un chèque d une remise pointée'
    end
  
  end

  
  def cant_destroy_when_pointed
    if bank_extract_line
    logger.warn "Tentative de détruire la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
    return false
    end
  end

 # mise à jour des lignes lorsque la remise chèques est pointée
  def update_checks_if_bank_extract_line
    if bank_extract_line
      logger.info "Mise à jour des lignes par before_save de check_deposit #{id} (méthode : update_checks_if_bank_extract_line"
       checks.each { |l| l.update_attributes(:bank_extract_id=>bank_extract_line.bank_extract.id)  }
    end
     
  end

  def update_bank_account_id_for_checks
    # puts "nombre de lignes : #{checks.size} -- bank_account_id : #{bank_account.id}"
    checks.each {|l| l.update_attribute(:bank_account_id, bank_account.id)}
  end


  def nil_bank_account_id(line)
    line.update_attribute(:bank_account_id, nil)
  end
  
end
