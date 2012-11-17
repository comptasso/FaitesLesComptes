# coding: utf-8

# Controller permettant d'afficher les différentes pages de restitution des comptes
# actif, passif, ...

class Compta::SheetsController < Compta::ApplicationController

  def index
    n = Compta::Nomenclature.new(@period, 'nomenclature.yml')
    @docs = params[:collection].map {|c| n.sheet(c.to_sym)}
    respond_to do |format|
        format.html 
        format.pdf
    end
  end


  def show
    @nomenclature = Compta::Nomenclature.new(@period, 'nomenclature.yml')
    @doc = @nomenclature.sheet(params[:id].to_sym)
    @option = params[:option]
    if @doc
    respond_to do |format|
        format.html 
        format.pdf
    end
    else
      flash[:error] = "Le document demandé #{params[:id]} n'a pas été trouvé "
      redirect_to :back
    end
  end

  def bilan
     redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:actif, :passif])
  end

  def resultats
     redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:exploitation, :financier, :exceptionnel])
  end


  def detail
    @detail_lines = @period.two_period_account_numbers.map  {|num| Compta::RubrikLine.new(@period, :actif, num)}
  end

end

