# -*- encoding : utf-8 -*-


module InOutWritingsHelper
  
 

  # permet d'afficher les actions possible
  def in_out_line_actions(line)
    html = ' '
      if line.writing.type == 'Transfer'
        html <<  icon_to('modifier.png', edit_transfer_path(line.writing_id)) if line.editable?
      else
        html <<  icon_to('modifier.png', edit_book_in_out_writing_path(line.writing.book_id, line.writing)) if line.editable?
        html <<  icon_to('supprimer.png', book_in_out_writing_path(line.writing.book, line.writing), confirm: 'Etes vous sûr?', method: :delete) if line.editable?
      end


    content_tag :td, :class=>'icon' do
      html.html_safe
    end
  end

    # Helper permettant de construire les options de counter_account pour le form
# La classe OptionsForAssociationSelect est dans lib
#
# Le deuxième argument indique si on veut une liste de compte pour une recette ou pour
# une dépense, la différence venant du traitement des chèques de recettes qui ne peuvent
# être mis que sur le compte chèque à l'encaissement
#
def options_for_cca(period, io = false)
 arr =  [OptionsForAssociationSelect.new('Banques', :list_bank_accounts, period),
    OptionsForAssociationSelect.new('Caisses',:list_cash_accounts, period)]
  if io == true
     arr << OptionsForAssociationSelect.new('Chèques à l\'encaissement', :rem_check_accounts, period)
  end
  arr
end



  end



 