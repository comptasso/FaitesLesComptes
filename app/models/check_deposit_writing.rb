# coding: utf-8


# La classe CheckDepositWriting est destinée à représenter les écritures
# qui sont créees par le logiciel lors de la création d'une remise de chèque
#
class CheckDepositWriting < Writing
  has_many :compta_lines, :dependent=>:destroy, foreign_key:'writing_id'
end
