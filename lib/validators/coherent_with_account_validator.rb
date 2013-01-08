# coding: utf-8

# Vérifie que la nature (éventuellement les) appartiennent
# bien à l'exercice qui correspond à la date indiquée pour l'écriture
class CoherentWithAccountValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)

        p = record.book.organism.find_period(value) rescue nil
 
        record.compta_lines.each do |cl|
          record.errors[attribute] << "incoherent" if (cl.account && (cl.account.period != p))
        end

      end
    end
