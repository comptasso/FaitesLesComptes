# -*- encoding : utf-8 -*-


module InOutWritingsHelper
  
  # TODO vérifier que ces méthodes soient bien testées

  # renvoie les destinations correspondant au secteur si l'organisme est sectorisé
  def sectored_destinations(org, book)
    if org.sectored?
      ar = book.sector.destinations
    else
      ar = org.destinations
    end
    ar.order('name').all
  end
  
  
  
  
  # Helper permettant de construire les options de counter_account pour le form
  # La classe OptionsForAssociationSelect est dans lib
  #
  # Le premier argument est l'exercice car on a besoin des numéros de compte, 
  # tandis que le deuxième est le livre qui permet de déduire le secteur 
  # 
  def options_for_cca(period, book)
    sector = book.sector
    arr =  [OptionsForAssociationSelect.
        new('Banques', :list_bank_accounts, sector, period),
      OptionsForAssociationSelect.
        new('Caisses',:list_cash_accounts, sector, period)]
    if book.income_outcome == true
      arr << OptionsForAssociationSelect.
        new('Chèques à l\'encaissement', :rem_check_accounts, period)
    end
    arr
  end
  
  # affichage des icones pour les éléments de classe Request::FrontLine
  # un peu différent d'une ligne standard. Pour les compta_lines, utiliser
  # le helper line_actions.
  def frontline_actions(frontline)
    # Si la ligne est éditable, alors on peut la modifier ou la supprimer
    # 
    # Si la ligne est un Transfer, la modification se fait via la rubrique Transfer
    # La suppression n'est pas possible, car elle doit passer par le menu Transfer
    html = ' '
    
    if frontline.editable?
      case frontline.writing_type
      when 'Transfer'
        html <<  icon_to('modifier.png', edit_transfer_path(frontline.id)) 
      when 'Adherent::Writing' then 
        html << icon_to('detail.png',
          adherent.member_payments_path(frontline.adherent_member_id))
      else
        html <<  icon_to('modifier.png', 
          edit_book_in_out_writing_path(frontline.book_id, frontline.id)) 
        html <<  icon_to('supprimer.png', 
          book_in_out_writing_path(frontline.book_id, frontline.id),
          confirm: 'Etes vous sûr?', method: :delete)
      end
    else 
      case frontline.writing_type
      when 'Transfer' then  html << icon_to('detail.png', 
          transfer_path(frontline.id))
      when 'Adherent::Writing' then
        html << icon_to('detail.png', 
          adherent.member_payment_path(frontline.adherent_member_id, 
            frontline.adherent_payment_id),
          title:'Table des paiments à l\'origine de cette écriture')
      else
        # on va donner des conseils à l'utilisateur pour comprendre pourquoi
        # il ne peut travailler l'image
        if frontline.cl_locked || frontline.support_locked
          html << image_tag('icones/nb_verrouiller.png', title:'Ecriture verrouillée, modification impossible')
        else
          html << image_tag('icones/nb_modifier.png', title:reason(frontline))
          html << '&nbsp'
          html << image_tag('icones/nb_supprimer.png', title:reason(frontline))
        end
        
      end
    end
    html.html_safe
  
  end
  
  # affiche pourquoi les icones modifier et supprimer sont en noir et blanc
  def reason(line)
    return 'Chèque inclus dans une remise de chèque,
  le retirer de la remise pour pouvoir l\'éditer' if line.support_check_id
    return 'Ecriture incluse dans un pointage de compte bancaire,
    le retirer du pointage pour pouvoir l\'éditer' if line.bel_id
  end

  # permet d'afficher les actions possible dans une ligne d'écriture
  # 
  def in_out_line_actions(line)
    content_tag :td, :class=>'icon' do
      line_actions(line)
    end
  end


  # renvoie les actions possibles sous forme d'un fragment de html 
  # pour une compta_line. 
  # Si un block est donné, les instructions de ce block sont reprises dans 
  # le fragment de html et au début de celui ci.
  # TODO voir si on utilise deletable dans le programme.
  def line_actions(line, deletable = true)
    html = ' '
    html += yield if block_given?
    lw=line.writing
    
    if lw.editable?
      html << actions_for_editable(lw, deletable=true)
    else 
      html << actions_for_not_editable(lw, deletable=true)
    end
    html.html_safe
  end
  
  protected
  
  
  # Si la ligne est éditable, alors on peut la modifier ou la supprimer
  # sauf pour les transferts et les écritures venant de la zone Adhérent
  def actions_for_editable(writing, deletable=true)
    html = ''
    case writing
    when Transfer
      html <<  icon_to('modifier.png', edit_transfer_path(writing.id)) 
    when Adherent::Writing then html << icon_to('detail.png', 
        adherent.member_payments_path(writing.member))
    else
      html <<  icon_to('modifier.png', 
        edit_book_in_out_writing_path(writing.book_id, writing)) 
      html <<  icon_to('supprimer.png', 
        book_in_out_writing_path(writing.book, writing),
        confirm: 'Etes vous sûr?', method: :delete) if deletable 
    end
    html
  end
  
  
  # lorsque la ligne n'est pas editable, alors on peut seulement afficher les 
  # informations de détail
  # TODO rajouter des icones N&B pour avoir un conseil pour les lignes 
  # pointées.
  def actions_for_not_editable(writing, deletable=true)
    html = ''
    case writing
    when Transfer then  html << icon_to('detail.png', transfer_path(writing.id))
    when Adherent::Writing then html << icon_to('detail.png', 
        adherent.member_payment_path(writing.member, writing.bridge_id),
        title:'Table des paiments à l\'origine de cette écriture')
    end
    html
  end



end



 
