module CheckDepositsHelper

  def button_for_check(check)  
    if check.bank_extract_id.nil?
      button_to "Ajouter", fill_bank_account_check_deposit_path(@bank_account.id, check.id), remote: true
    else
      button_to "Retirer", fill_bank_account_check_deposit_path(@bank_account.id, check.id), remote:true
    end
  end
end
