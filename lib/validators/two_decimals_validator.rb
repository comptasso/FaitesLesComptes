# coding: utf-8
#
# Ce fichier permet de vérifier le format des saisies de montants monétaires
# qui peuvent donc être un chiffre négatif, avec ou sans décimales
#
#

class TwoDecimalsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless (value.to_s =~ /^(\+|\-)?\d+(\.\d{0,2})?$|^\.\d{0,2}$/)      #\.?\d{0,2}/
        record.errors[attribute] << "#{value} is not a valid amount for #{attribute} - max decimals number is 2"  
      end
      # =~ 
    end
  end
