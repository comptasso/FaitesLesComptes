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
    if @doc
      respond_to do |format|
        format.html 
        format.pdf
      end
    else
      flash[:alert] = "Le document demandé #{params[:id]} n'a pas été trouvé "
      redirect_to compta_period_nomenclature_url(@period)
    end
  end

  def bilans
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:actif, :passif])
  end

  def resultats
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:exploitation, :financier, :exceptionnel])
  end


  # pluriel volontaire pour le distinguer de show/benvolat qui montre le détail de la page benevolat
  # tandis qu'ici on veut l'action index, mais avec une collection d'un seul élément
  # ce qui perturbe le routage
  # Ici avec sheets/benevolats, on est bien différent de sheets/benevolat qui est routée sur show
  def benevolats
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:benevolat])
  end


  def detail
    @detail_lines = @period.two_period_account_numbers.map  {|num| Compta::RubrikLine.new(@period, :actif, num)}
  end

end

