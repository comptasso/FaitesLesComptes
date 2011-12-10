module CheckDepositsHelper

  def button_for_check(check)  
    if check.bank_extract_id.nil?
      button_to "Ajouter", add_check_bank_account_check_deposit_path(@bank_account, @check_deposit), remote: true, :line_id=>check.id
    else
      button_to "Retirer", remove_check_bank_account_check_deposit_path(@bank_account, @check_deposit), remote:true, :line_id=>check.id
    end
  end
end
