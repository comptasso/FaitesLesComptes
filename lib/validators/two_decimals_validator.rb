# coding: utf-8
#
# Ce fichier permet de vérifier le format des saisies de montants monétaires
# qui peuvent donc être un chiffre négatif, avec ou sans décimales,
# avec éventuellement un signe -
#
#

class TwoDecimalsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless (value.to_s =~ /^(\+|\-)?(\d+(\.\d{0,2})?|\.\d{1,2})$/)
        record.errors.add(attribute,  :two_decimals)
      end
    end
  end
