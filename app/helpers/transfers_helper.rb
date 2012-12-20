module TransfersHelper

  # definit le label des comtpes des compta_lines d'un Transfer
  # soit De pour la seconde, soit Vers pour la première
  # Voir l'ordre choisi par convention dans le modèle Transfer
  def transfer_label(cl)
    if cl == @transfer.compta_lines.first
      'De'
    else
      'Vers'
    end
  end
 
end
