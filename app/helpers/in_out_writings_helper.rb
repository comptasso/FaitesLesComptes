# -*- encoding : utf-8 -*-


module InOutWritingsHelper
  
  # TODO vérifier que ces méthodes soient bien testées

  # renvoie les destinations correspondant au secteur si l'organisme est sectorisé
  def sectored_destinations(org, book)
    if org.sectored?
      ar = book.sector.destinations.used_filtered
    else
      ar = org.destinations.used_filtered
    end
    ar.order('name').to_a
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
        new('Banques',  :list_bank_accounts_with_communs, sector, period),
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
    # TODO retirer la question du Transfer qui n'apparait pas dans 
    # les in_out_writings ?
    # Si la ligne est un Transfer, la modification se fait via la rubrique Transfer
    # La suppression n'est pas possible, car elle doit passer par le menu Transfer
    html = ' '
    
    
    
    
    if frontline.editable?
      case frontline.writing_type
      when 'Transfer'
        html <<  icon_to('modifier.png', edit_transfer_path(frontline.id)) 
      when 'Adherent::Writing' then 
        html << frontline_actions_for_adherent_writing(frontline)
      else
        # on commence par ajouter une icone de détail
        html << icon_to('detail.png',
          book_in_out_writing_path(frontline.book_id, frontline.id), 
          title:'Infos complémentaires', remote:true )
        html <<  icon_to('modifier.png', 
          edit_book_in_out_writing_path(frontline.book_id, frontline.id)) 
        html <<  icon_to('supprimer.png', 
          book_in_out_writing_path(frontline.book_id, frontline.id),
          data:{confirm: 'Etes vous sûr?'}, method: :delete)
      end
    else 
      case frontline.writing_type
      when 'Transfer' then  html << icon_to('detail.png', 
          transfer_path(frontline.id))
      when 'Adherent::Writing' then
        html << frontline_actions_for_adherent_writing(frontline)
      else
        # on commence par ajouter une icone de détail
        html << icon_to('detail.png',
          book_in_out_writing_path(frontline.book_id, frontline.id), 
          title:'Infos complémentaires', remote:true )
        # on va donner des conseils à l'utilisateur pour comprendre pourquoi
        # il ne peut pas éditer cette écriture
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
  # ne fait qu'entourer d'une balise td.icon le résultat de line_actions
  def in_out_line_actions(line)
    content_tag :td, :class=>'actions' do
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
    when Adherent::Writing then html << actions_for_adherent_writing(writing)
    when InOutWriting
      html <<  icon_to('modifier.png', 
        edit_book_in_out_writing_path(writing.book_id, writing)) 
      html <<  icon_to('supprimer.png', 
        book_in_out_writing_path(writing.book_id, writing),
        data:{confirm: 'Etes vous sûr?'}, method: :delete) if deletable
    else # cas d'une Writing passée par le journal d'OD, on va sur le module
      # compta
      html <<  icon_to('modifier.png', 
        edit_compta_book_writing_path(writing.book_id, writing)) 
      html <<  icon_to('supprimer.png', 
        compta_book_writing_path(writing.book_id, writing),
        data:{confirm: 'Etes vous sûr?'}, method: :delete) if deletable
    end
    html 
  end
  
  # Renvoie vers l'écriture à l'origine du paiement. 
  # Si le membre n'est pas trouvé, affiche une icone désactivée.
  def actions_for_adherent_writing(writing)
    if wm = writing.member
      icon_to('detail.png', 
        adherent.member_payment_path(wm, writing.bridge_id),
        title:'Paiement à l\'origine de cette écriture')
    else
      image_tag('icones/nb_detail.png', 
        title:'L\'adhérent semble avoir été effacé - Impossible d\'afficher l\'origine de ce paiement')
    end
  end
  
  # Pour éviter de renvoyer vers un adhérent supprimé, on teste member_id
  # et on affiche des icones et actions en conséquence.
  def frontline_actions_for_adherent_writing(frontline)
    if frontline.member_id
      icon_to('detail.png',
        adherent.member_payment_path(frontline.member_id, 
          frontline.adherent_payment_id ),
        title:'Paiment à l\'origine de cette écriture')
    else
      image_tag('icones/nb_detail.png', 
        title:'L\'adhérent semble avoir été effacé - Impossible d\'afficher l\'origine de ce paiement')
    end
  end
  
  
  # lorsque la ligne n'est pas editable, alors on peut seulement afficher les 
  # informations de détail
  # TODO rajouter des icones N&B pour avoir un conseil pour les lignes 
  # pointées.
  def actions_for_not_editable(writing, deletable=true)
    html = ''
    case writing
    when Transfer then  html << icon_to('detail.png', transfer_path(writing.id))
    when Adherent::Writing then html << actions_for_adherent_writing(writing)
    end
    html
  end



end



 
