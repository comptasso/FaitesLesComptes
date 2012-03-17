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

    if org.number_of_non_deposited_checks > 0
      info= {}
      info[:text] = "<b>#{org.number_of_non_deposited_checks} chèques à déposer</b> pour \
            un montant total de #{number_to_currency org.value_of_non_deposited_checks}".html_safe
      info[:icon] = icon_to('nouveau.png', new_organism_check_deposit_path(org))
      m << info
    end

    org.bank_accounts.each  do |ba|
      if ba.bank_extracts.any? && !ba.bank_extracts.last.locked
        info={}
        info[:text] = "Compte <b>#{sanitize ba.number}</b> : Le pointage du dernier relevé n'est pas encore effectué".html_safe
        info[:icon] = icon_to 'pointer.png', pointage_organism_bank_account_bank_extract_path(org,ba, ba.first_bank_extract_to_point)
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
        delta =((cash_control.amount - ca.sold(cash_control.date)).abs)
        if delta > 0.001
          info[:text] = "Caisse <b>#{sanitize ca.name}</b> : Ecart de caisse de  #{delta}" if delta > 0.001
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
    when 'BankAccount' then ['bank_pave','bank_account']
    when 'Cash' then ['cash_pave', 'cash']
    end
    render partial: partial_and_class[0], object: p,  locals: {:position => "#{partial_and_class[1]} #{html_class}" }
  end

 

end

