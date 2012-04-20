# -*- encoding : utf-8 -*-
module CashLinesHelper


  # helper pour afficher les actions d'une cash line,
  # la modification doit se faire par transfer si la ligne vient d'un virement
  # ou est en direct si c'est la ligne est une écriture saisie d'un livre de
  # recettes ou de dépenses.
  # TODO cette méthode pourrait être commune avec lines et être également partagée
  # avec bank_lines..
  def cash_line_actions(line)
    html = ''
      if line.owner_type == 'Transfer'
        html <<  icon_to('modifier.png', edit_transfer_path(line.owner_id)) unless line.locked?
      else
        html <<  icon_to('modifier.png', edit_book_line_path(line.book_id, line)) unless line.locked?
        html <<  icon_to('supprimer.png', [line.book,line], confirm: 'Etes vous sûr?', method: :delete) unless line.locked?
      end
      

    content_tag :td, :class=>'icon' do
      html.html_safe
    end

  end
  
end
