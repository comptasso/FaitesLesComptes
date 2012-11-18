# coding: utf-8

# Controller permettant d'afficher les différentes pages de restitution des comptes
# actif, passif, ...

class Compta::SheetsController < Compta::ApplicationController
  
  before_filter :check_nomenclature, :only=>[:index, :show]


  def index
    
    @docs = params[:collection].map {|c| @nomenclature.sheet(c.to_sym)}
    respond_to do |format|
      format.html
      format.csv { 
        datas = ''
        @docs.each {|doc| datas += doc.to_index_csv }
        send_data datas
        }
      format.xls { 
        datas = ''
        @docs.each {|doc| datas += doc.to_index.xls}
        send_data datas
      }
    end
  end


  def show
    
    @doc = @nomenclature.sheet(params[:id].to_sym)
    if @doc
      respond_to do |format|
        format.html 
        format.csv { send_data @doc.to_csv  }  # \t pour éviter le problème des virgules
        format.xls { send_data @doc.to_xls  }
      end
    else
      flash[:alert] = "Le document demandé : #{params[:id]}, n'a pas été trouvé "
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

  protected

  def check_nomenclature
    @nomenclature = Compta::Nomenclature.new(@period, 'nomenclature.yml')
    unless @nomenclature.valid?
      al = 'La nomenclature utilisée comprend des incohérences avec le plan de comptes. Les documents produits risquent d\'être faux.</br> '
      al += 'Liste des erreurs relevées : <ul>'
      @nomenclature.errors.full_messages.each do |m|
        al += "<li>#{m}</li>"
      end
      al += '</ul>'
      flash[:alert] = al.html_safe
    end
  end

end

