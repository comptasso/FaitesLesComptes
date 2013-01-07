# coding: utf-8

# NatureCoherentWithDate vérifie que la natures (éventuellement les) appartiennent
# bien à l'exercice qui correspond à la date indiquée pour l'écriture
class AccountCoherentWithDateValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
      unless record.book
        record.errors[:book] << "Livre manquant"
        return
      end
      unless record.date && record.date.is_a?(Date) # la date est déjà vérifiée par un MustBelongToPeriod
        record.errors[:date] << "Date obligatoire"
        return
      end
      
        p = record.book.organism.find_period(record.date)
        

        record.compta_lines.each do |cl|
          record.errors[:date] << "Le compte n'est pas de cet exercice" if (cl.account && (cl.account.period != p))
        end

      end
    end
