# coding: utf-8

# Controller permettant d'afficher les différentes pages de restitution des comptes
# actif, passif, ...
# la vue index prende une collection en paramètres et peut ainsi afficher un
# bilan (actif et passif), un compte de résultats (exploitation, financier, exceptionnel)
# mais aussi sert de vue (show) en n'appelant qu'un seul élémnent (actif par exemple)

load "#{Rails.root}/lib/pdf_document/pdf_rubriks.rb"

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
        @docs.each {|doc| datas += doc.to_index_xls}
        send_data datas, :filename=>"#{params[:title] || params[:collection]}.csv"
        }
    end
  end

  # l'action show montre la construction de la sheet en détaillant pour chaque rubrique
  # les comptes qui ont contribué au calcul
  #
  def show
    
    @sheet = @nomenclature.sheet(params[:id].to_sym)
    if @sheet
      respond_to do |format|
        format.html 
        format.csv { send_data @sheet.to_csv  }  # \t pour éviter le problème des virgules
        format.xls { send_data @sheet.to_xls  }
        format.pdf { send_data @sheet.to_pdf.render}
      end
    else
      flash[:alert] = "Le document demandé : #{params[:id]}, n'a pas été trouvé "
      redirect_to compta_period_nomenclature_url(@period)
    end
  end

  # bilans est une action accessoire qui renvoie vers index avec actif et passif comme 
  # paramètres de collection
  def bilans
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:actif, :passif], :title=>'Bilan')
  end

  # resultats renvoie vers index avec exploitation, financier et exceptionnel
  def resultats
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:exploitation, :financier, :exceptionnel],
    :title=>'Résultats')
  end

  # pluriel volontaire pour le distinguer de show/benvolat qui montre le détail de la page benevolat
  # tandis qu'ici on veut l'action index, mais avec une collection d'un seul élément
  # ce qui perturbe le routage
  # Ici avec sheets/benevolats, on est bien différent de sheets/benevolat qui est routée sur show
  def benevolats
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:benevolat], :title=>'Bénévolat')
  end


  # dernière action de ce controller, detail donne les valeurs des comptes pour l'ensemble des 
  # comptes avec leur rattachement aux riburik adéquates.
  # c'est une sorte de balance mais en fin d'exercice et avec les comptes de l'exercice mais 
  # aussi de l'exercice précédent
  def detail
    @detail_lines = @period.two_period_account_numbers.map  {|num| Compta::RubrikLine.new(@period, :actif, num)}
    respond_to do |format|
        format.html
        format.csv { send_data @detail_lines.inject('') {|i, line|  i += line.to_csv  } } 
        format.xls { send_data(@detail_lines.inject('') {|i, line|  i += line.to_xls  }, :filename=>'detail.csv')   }
      end
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

