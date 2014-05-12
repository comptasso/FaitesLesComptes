# coding: utf-8

# Utilisé par les ImportedBels pour vérifier que débit et crédit ne sont 
# pas nuls simultanément.
# 
# Ajoute une erreur sur la ligne (:row) plutôt que sur débit et crédit
class NotBothNullOrFullValidator < ActiveModel::Validator 

  def validate(record)
    return unless record.errors[:values].empty?
    if record.debit == 0 && record.credit == 0
      record.errors.add(:values, :both_null) # 'débit et crédit tous deux à zéro'
    end
    if record.debit != 0 && record.credit != 0
      record.errors.add(:values, :both_full)
    end
    
    
  end

end