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
#          puts "Nature #{cl.nature.id} de la périod #{cl.nature.period.id} alors que l'on veut #{p.id}" if cl.nature
#          puts 'je détecte une erreur' if (cl.nature && (cl.nature.period != p))
          cl.errors[:account] << "Compte n'est pas de cet exercice" if (cl.account && (cl.account.period != p))
        end

      end
    end
