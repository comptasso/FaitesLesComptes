# coding: utf-8
#
# permet de bloquer l'édition de tous les champs sauf validated lorsque validated est à true
# s'utilise en mettant validates :field, :cant_edit=>true
# 
# cela permet par exemple d'écrire validates :line_date, :debit, :credit,... , :cant_edit=>true, :if=>:locked?
# un warn est envoyé sur le log ce qui pourra permettre d'identifier des actions illogiques
# 
# Voir aussi CantChangeValidator pour les attributs qui sont destinés à ne jamais changer,
# comme un numéro de compte.
#
class CantEditValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
     if record.changed_attributes[attribute.to_s] 
      Rails.logger.warn "tentative pour modifier #{attribute} alors que le #{record} est verrouillé"
      record.errors.add(attribute, :locked)
     end
  end
end