# -*- encoding : utf-8 -*-

module OrganismsHelper


  
  def infos(org)

    m=[]
    if org.number_of_non_deposited_checks > 0
      info= {}
      info[:text] = "#{org.number_of_non_deposited_checks} chèques à déposer pour \
            un montant total de #{number_to_currency org.value_of_non_deposited_checks}"
      info[:icon] = icon_to('nouveau.png', new_organism_check_deposit_path(org))
    m << info
    end

    org.bank_accounts.each  do |ba|
      if ba.bank_extracts.any? && !ba.bank_extracts.last.locked
        info={}
        info[:text] = "Compte #{ba.number} : Le pointage du dernier relevé n'est pas encore effectué"
        info[:icon] = icon_to 'pointer.png', pointage_organism_bank_account_bank_extract_path(org,ba, ba.first_bank_extract_to_point)
        m << info
      end
    end
    org.cashes.each do |ca|
      
      unless ca.cash_controls.any?
        info={}
      info[:text] = "Caisse #{ca.name} : Pas encore de contrôle de caisse à ce jour"
      info[:icon] = icon_to 'pointer.png', new_cash_cash_control_path(ca)
      m << info
      end
      if ca.cash_controls.any?
        info={}
         cash_control = ca.cash_controls.order('date ASC').last
         delta =((cash_control.amount - ca.sold(cash_control.date)).abs)
         if delta > 0.001
            info[:text] = "Caisse #{ca.name} : Ecart de caisse de  #{delta}" if delta > 0.001
            info[:icon] = icon_to 'detail.png', cash_cash_control_path(ca, cash_control)
            m << info
         end
       end
    end
    return m
  end

  

end

