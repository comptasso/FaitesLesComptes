module TransfersHelper

  # definit le label des comtpes des compta_lines d'un Transfer
  # soit De pour la première, soit Vers pour la seconde
  def transfer_label(cl)
    if cl == @transfer.compta_lines.first
      'De'
    else
      'Vers'
    end
  end
 
end
