# coding: utf-8


# La classe CheckDepositWriting est destinée à représenter les écritures
# qui sont créees par le logiciel lors de la création d'une remise de chèque
#
class CheckDepositWriting < Writing
  has_many :compta_lines, :dependent=>:destroy, foreign_key:'writing_id'
  has_one :check_deposit, foreign_key:'writing_id'
  
  protected
  
  # Pour les remises de chèques, la date de pièce est la date opération
  def fill_date_piece
    self.date_piece = date
  end
end
