# coding: utf-8

# Le module extract définit la classe de base pour les extraits de quelque chose
# ayant une méthode lines renvoyant un objet capable de faire une somme sur
# ses attributs débit et crédit
#
module Extract
  class Base

    def lines
      raise 'implement this method in children class'
    end

    def total_debit
      lines.sum(:debit)
    end

    def total_credit
      lines.sum(:credit)
    end
  end
end
