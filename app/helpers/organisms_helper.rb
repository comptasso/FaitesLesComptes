# -*- encoding : utf-8 -*-

module OrganismsHelper
 
  # Méthode pour afficher les messages venant des différents modèles.
  # 
  # infos appelle successivement les différents méthodes pour chacun des objets
  # générant des messages.
  #
  def infos(org)
    m=[]
    m << session[:messages] unless session[:messages].nil?
    m << check_deposit_message(org)
    org.bank_accounts.each  { |ba| m << bank_account_message(ba) }
    org.cashes.each { |ca| m << cash_message(ca) }
    org.subscriptions.each { |sub| m << sub_infos(sub) }
    return m.compact # pour retirer les éventuels messages nil
  end
  
  

  # Appelé par la vue organism#show pour dessiner chacun des pavés qui figurent 
  # dans le dash board.
  # 
  # Le dashboard comprend plusieurs types de pavés :
  # - ceux correspondant aux livres de recettes et de dépenses
  # - ceux correspondant aux secteur
  # - enfin ceux correspondant aux caisses et aux comptes bancaires (générés par 
  # des cash_books ou des bank_books)
  # - un des pavé de type resultat est généré par period et cumule donc les résultats des
  # pavés des secteurs
  # 
  # 
  # html_class, permet d'associer des classes à chacun des pavés, sachant qu'actuellement
  # l'appel dans la vue show est systématiquement fait avec la classe span4
  # 
  # 
  def draw_pave(source, period, html_class)
    if source
      render partial: "organisms/#{pave_partial(source)}", object: source,  
        locals: {:local_classes => "#{local_class(source)} #{html_class}", :graph=>source.graphic(period) }
    else
      ''
    end
  end

  # Gère mieux que pluralize le fait que num soit == à zero
  def vous_avez_des_messages(num)
    html = if (num == 0)
      "Aucun message "
    else
      "Vous avez #{pluralize(num, 'message')} "
    end
    html += image_tag 'icones/mail-open.png', id: 'mail_img' unless num == 0
    html.html_safe
  end
  
  protected
  
  # Produit les messages lié à la présence de chèques à déposer
  # 
  # Les arguments sont org (l'organisme) et cdnb, le nombre de chèques à déposer
  # On utilise directement la table CheckDeposit car on est dans une logique de
  # schéma.
  # 
  # TODO : voir si on garde cette logique au cas où on voudrait revenir à une 
  # logique plus classique.
  #
  def check_deposit_message(org)
     if (cdnb = CheckDeposit.nb_to_pick) > 0
      info= {}
      info[:text] = "<b>#{cdnb} chèques à déposer</b> pour \
            un montant total de #{number_to_currency CheckDeposit.total_to_pick}".html_safe
      info[:icon] = icon_to('nouveau.png', new_organism_bank_account_check_deposit_path(org, org.main_bank_id))
     else
      info = nil
     end
     info
  end
  
  # Une banque peut envoyer un message s'il y a un relevé de compte non pointé
  # Renvoie nil sinon
  def bank_account_message(ba)
    be_to_point = ba.bank_extracts.period(@period).unlocked
      if be_to_point.any?
        info={}
        info[:text] = "<b>#{sanitize ba.nickname}</b> : Le pointage du dernier relevé n'est pas encore effectué".html_safe
        info[:icon] = icon_to 'pointer.png', pointage_bank_extract_bank_extract_lines_path(be_to_point.first)
      else
        info = nil
      end
    info
  end
  
  def cash_message(ca)
    info = {}
      if ca.cash_controls.any?
        cash_control = ca.cash_controls.order('date ASC').last
        if cash_control.different?
          info[:text] = "Caisse <b>#{sanitize ca.name}</b> : Ecart de caisse de  #{cash_control.difference}".html_safe
          info[:icon] = icon_to 'detail.png', cash_cash_controls_path(ca)
        else
          info = nil
        end
      else
        info[:text] = "Caisse <b>#{sanitize ca.name}</b> : Pas encore de contrôle de caisse à ce jour".html_safe
        info[:icon] = icon_to 'pointer.png', new_cash_cash_control_path(ca)
      end
    info
  end
  
  # indique quelle est la classe css à appliquer pour la graphique dont la source est
  # donnée par source
  def local_class(source)
    case source.class.name
      when 'VirtualBook' then source.virtual.class.name.underscore
    else 
      source.class.name.underscore
    end
  end
  
  def pave_partial(source)
    case source.class.name
    when "Sector" then 'sector_pave'
    when "VirtualBook" then 'line_pave'
    else 'bar_pave'
    end
  end


  






end

