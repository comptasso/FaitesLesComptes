# -*- encoding : utf-8 -*-

module OrganismsHelper

  def infos(org)
    m=[]
    if org.number_of_non_deposited_checks > 0
      m << "#{@organism.number_of_non_deposited_checks} chèques à déposer pour \
            un montant total de #{two_decimals @organism.value_of_non_deposited_checks} #{image_tag 'nouveau.png'}"
#           #{icon_to 'nouveau.png'}, new_organism_check_deposit_path(org)}
    end
    org.bank_accounts.each  do |ba|
      if ba.bank_extracts.any?
        m <<  "Compte #{ba.number} : Le pointage du dernier relevé n'est pas encore effectué" unless ba.bank_extracts.last.locked
      end
    end
    org.cashes.each do |ca|
      if ca.cash_controls.any?
        cash_control = ca.cash_controls.order('date ASC').last
        delta=(cash_control.amount - ca.sold(cash_control.date)).abs
        m << "Caisse #{ca.name} : Dernier contrôle de caisse en date du #{l ca.cash_controls.order('date ASC').last.date}"
        m << "Ecart de caisse de  #{delta}" if delta > 0.001
      else
        m << "Caisse #{ca.name} : Pas encore de contrôle de caisse à ce jour"
      end
    end
    return m
  end

  

end

