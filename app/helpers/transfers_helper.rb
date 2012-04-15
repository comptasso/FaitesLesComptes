module TransfersHelper

  # Un transferable peut être un compte bancaire ou un virement
  # show_transferable choisit l'affichage qui convient en fonction de la
  # class du modèle
  #
  def show_transferable(dc)
    case dc.class.name
    when 'BankAccount' then dc.to_s
    when 'Cash' then dc.name
    else 'Erreur'

    end
  end

end
