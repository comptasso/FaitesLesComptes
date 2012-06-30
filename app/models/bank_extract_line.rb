# coding: utf-8


# La classe sert de mère pour les différents types de BankExtractLine avec une
# seule table (STI)
#
# Le modèle BanExtractLine représente une ligne d'un relevé bancaire.
#
# Cette ligne peut correspondre à une ligne d'un livre de recettes ou de dépenses
# du moment qu'il s'agit d'une opération bancaire (pas d'espèces évidemment).
# Par exemple un prélèvement ou un virement
# Mais ce peut être aussi une remise de chèque.qui elle même renvoie à plusieurs lignes.
#
# Le modèle a des sous classes :
# - StandardBankExtractLine
# - CheckDepositBankExtractLine
# et est représenté par une table avec les champs date, position, type, bank_extract_id
# et check_deposit_id (ce dernier champ ne servant que pour la sous classe
# CheckDepositBankExtractLine
#
# La méthode de classe has_many est surchargée dans CheckDepositBankExtractLine
# pour pouvoir renvoyer les lines de la remise de chèque associées
#
# Une relation HABTM est définie avec lines, permettant d'avoir une ligne de relevé
# bancaire qui correspond à plusieurs lignes d'écriture (ex péages regroupés
# par semaine par les sociétés d'autoroute mais dont les dépenses sont enregistrées
# ticket par ticket.
#
# Ou à l'inverse une ligne de dépenses qui aurait donné lieu à une opération bancaire
# détaillée en deux lignes sur le relevé.
#
# Acts as list permet d'utiliser le champ position pour ordonner les lignes du relevé
#
class BankExtractLine < ActiveRecord::Base

  # TODO mettre une restriction pour transformer ce modèle en modèle virtuel

  belongs_to :bank_extract

  has_and_belongs_to_many :lines, :before_add=>:not_already_included

  acts_as_list :scope => :bank_extract

  # validate :not_empty est délégué aux sous classes
  # par le biais de check_deposit_id :presence=>true
  # et par le biais d'une mathode not_empty pour StandardBankExtractLine

  attr_reader :payment, :narration, :debit,  :credit

  before_destroy :remove_from_list  #est défini dans le plugin acts_as_list

 
  # chainable indique si le bank_extract_line peut être relié à son suivant
  # Ce n'est possible que si
  #  - ce n'est pas une remise de chèque
  #  - ce n'est pas le dernier
  #  - ils ne sont pas du même sens.
  #  - le suivant n'est pas une remise de chèque
  #
  def chainable?
    return false if is_a?(CheckDepositBankExtractLine)
    return false unless lower_item
    return false if (lower_item.debit == 0 && self.debit != 0) || (self.credit != 0 && lower_item.credit == 0)
    return false if  lower_item.is_a?(CheckDepositBankExtractLine)
    true
  end


  # appelé par before_add pour s'assurer que la ligne n'est pas déja rattachée
  # à une ligne d'un relevé bancaire
  def not_already_included(line)
    if line.bank_extract_lines.count > 0
      logger.warn "tried to include line #{line.id} which was already included in a bank_extract_line"
      raise ArgumentError
    end
  end

   # ActiveRecord::Base.restore est définie dans restore_record.rb
   # prepare_datas n'a aucune utilité dans la phase de restauration et génèrerait une
   # erreur puisque les lignes ne sont pas encore associées
   # validate not_empty doit aussi être désactivée le temps de recréer l'association
  def self.restore(new_attributes)
    # ce callback add_to_list_bottom vient du plugin acts_as_list
    BankExtractLine.skip_callback(:create, :before, :add_to_list_bottom) 

    restored = self.new(new_attributes)
       Rails.logger.info "création de #{restored.class.name} with #{restored.attributes}"
      # Rails.logger.warn "Erreur : #{restored.errors.inspect}" unless restored.valid?
       restored.save!(:validate=>false) # lors de la restauration la validation not_empty ne peut être effectuée
       restored
  ensure
     BankExtractLine.set_callback(:create, :before, :add_to_list_bottom)


  end



  
end
