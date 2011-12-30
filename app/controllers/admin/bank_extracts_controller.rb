# -*- encoding : utf-8 -*-

# Les extraits bancaires ne sont pas du domaine de la zone admin,
# cependant dans la zone de saisie, lorsqu'un extrait est pointé, il n'y a plus
# d'accès pour le modifier, le supprimer, et le pointer.
# La vue index permet alors de retrouver ces liens pour les extraits ce qui
# permet de supprimer un extrait pour le refaire si on le souhaite.
#
# Cele veut dire qu'on pourrait avoir accès à la suppression d'extraits
# par l'interface publique en rentrant directement dans la ligne d'adresse.
#
class Admin::BankExtractsController < Admin::ApplicationController

  before_filter  :find_bank_account

  # GET /bank_extracts
  # GET /bank_extracts.json
  def index
    @bank_extracts = @bank_account.bank_extracts.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_extracts }
    end
  end

  def unlock
    @bank_extract= BankExtract.find(params[:id])
    @bank_extract.update_attribute(:locked, false)
    redirect_to admin_organism_bank_account_bank_extracts_path(@organism, @bank_account)
  end


  private

  def find_bank_account
    @bank_account=BankAccount.find(params[:bank_account_id])
  end

end
