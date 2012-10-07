# -*- encoding : utf-8 -*-


module InOutWritingsHelper
  
 

  # helper pour afficher les actions d'une cash line,
  #  En effet la modification (edit) d'une cash_line doit se faire par transfer
  #  si la ligne vient d'un virement
  # ou est en direct si c'est la ligne est une écriture saisie d'un livre de
  # recettes ou de dépenses.
  # TODO cette méthode pourrait être commune avec lines et être également partagée
  # avec bank_lines..
  def in_out_line_actions(line)
    html = ' '
      if line.owner_type == 'Transfer'
        html <<  icon_to('modifier.png', edit_transfer_path(line.owner_id)) if line.editable?
      else
        html <<  icon_to('modifier.png', edit_book_in_out_writing_path(line.owner.book_id, line.owner)) if line.editable?
        html <<  icon_to('supprimer.png', [line.owner.book, line.owner], confirm: 'Etes vous sûr?', method: :delete) if line.editable?
      end


    content_tag :td, :class=>'icon' do
      html.html_safe
    end

  end



 



end
