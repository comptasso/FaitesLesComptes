# La clase Adherent::Writing est une classe dérivée de Writing et destinée
# à faire le lien entre le gem Adherent et l'application.
#
# Le PaymentObserver qui observe les Adherent::Payments crée, modifie ou
# supprime un élément Adherent::Writing.
#
#  Cette classe est en fait la copie conforme de InOutWriting avec
#  deux méthodes supplémentaires #payment et #member qui permettent
#  de faire le lien avec le payment.
#
module Adherent
  class Writing < ::InOutWriting


    def payment
      Adherent::Payment.find_by_id(bridge_id)
    end


    # renvoie le membre ayant réalisé le payment correspondant à cette écriture
    #
    # Cette méthode est utile pour faire le lien entre les vues des livres et
    # la vue des payments dans le module Adherent
    def member
      payment.member
    end


  end

end
