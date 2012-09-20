# -*- encoding : utf-8 -*-

module OrganismsHelper
 
  def infos(org)

    m=[]
    if org.natures.count == 0
      info = {}
      info[:text] = "Vous devez créez des natures de recettes et de dépenses pour pouvoir saisir des écritures dans les livres"
      info[:icon] = icon_to('nouveau.png', new_admin_organism_period_nature_path(org, @period), title: 'Créer une nature')
      m << info
    end

    if (cdnb = CheckDeposit.nb_to_pick) > 0
      info= {}
      info[:text] = "<b>#{cdnb} chèques à déposer</b> pour \
            un montant total de #{number_to_currency CheckDeposit.total_to_pick}".html_safe
      info[:icon] = icon_to('nouveau.png', new_organism_check_deposit_path(org))
      m << info
    end

    org.bank_accounts.each  do |ba|
      if ba.bank_extracts.any? && !ba.bank_extracts.last.locked
        info={}
        info[:text] = "Compte <b>#{sanitize ba.number}</b> : Le pointage du dernier relevé n'est pas encore effectué".html_safe
        info[:icon] = icon_to 'pointer.png', pointage_bank_extract_bank_extract_lines_path(ba.first_bank_extract_to_point)
        m << info
      end
    end
    org.cashes.each do |ca|
      
      unless ca.cash_controls.any?
        info={}
        info[:text] = "Caisse <b>#{sanitize ca.name}</b> : Pas encore de contrôle de caisse à ce jour".html_safe
        info[:icon] = icon_to 'pointer.png', new_cash_cash_control_path(ca)
        m << info
      end
      if ca.cash_controls.any?
        info={}
        cash_control = ca.cash_controls.order('date ASC').last
        if cash_control.different?
          info[:text] = "Caisse <b>#{sanitize ca.name}</b> : Ecart de caisse de  #{cash_control.difference}".html_safe
          info[:icon] = icon_to 'detail.png', cash_cash_control_path(ca, cash_control)
          m << info
        end
      end
    end
    return m
  end

  # appelé par la vue organism#show pour dessiner chacun des pavés qui figurent 
  # dans le dash board.
  def draw_pave(p, html_class)
    partial_and_class =   case p.class.name
    when 'IncomeBook' then  ['book_pave','income_book']
    when 'OutcomeBook' then  ['book_pave', 'outcome_book']
    when 'Period' then ['result_pave', 'result']
#   when 'BankAccountBook' then ['bank_pave','bank_account_book']
#   when 'CashBook' then ['cash_pave', 'cash_book']
    end
    render partial: "organisms/#{partial_and_class[0]}", object: p,  locals: {:local_classes => "#{partial_and_class[1]} #{html_class}" }
  end


  # menu prend une chaine de caractère représentant un modèle et 
  # et crée les entrées Afficher et Nouveau
  def menu(model)
    content_tag(:ul, :class=>"dropdown-menu") do
      content_tag(:li) { link_to 'Afficher', eval("organism_#{model.pluralize}_path(@organism)") } +
      content_tag(:li) {link_to 'Nouveau', eval("new_organism_#{model}_path(@organism)") }
    end
  end






end

