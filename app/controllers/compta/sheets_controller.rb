# coding: utf-8

# Controller permettant d'afficher les différentes pages de restitution des comptes
# actif, passif, ...
# la vue index prende une collection en paramètres et peut ainsi afficher un
# bilan (actif et passif), un compte de résultats (exploitation, financier, exceptionnel)
# mais aussi sert de vue (show) en n'appelant qu'un seul élémnent (actif par exemple)

#load "#{Rails.root}/lib/pdf_document/pdf_rubriks.rb"
#
#load "#{Rails.root}/lib/pdf_document/pdf_sheet.rb"
#load "#{Rails.root}/lib/pdf_document/pdf_detailed_sheet.rb"

 require 'pdf_document/base'

class Compta::SheetsController < Compta::ApplicationController
  
  before_filter :check_nomenclature, :only=>[:index, :show]

  # TODO ? faire un check de la validité de chaque document ?
  # ou le vérifier dans nomenclature.rb
  def index
    @docs = params[:collection].map {|c| @nomenclature.sheet(c.to_sym)}
    respond_to do |format|
      cookies[:export_token] = { :value =>params[:token], :expires => Time.now + 1800 }
      format.html
      format.csv { 
        datas = ''
        @docs.each {|doc| datas += doc.to_index_csv } 
        send_data datas
        }
      format.xls {
        datas = ''
        @docs.each {|doc| datas += doc.to_index_xls}
        send_data datas, :filename=>"#{params[:title] || params[:collection]}.xls"
        }

      format.pdf {
        final_pdf = Prawn::Document.new(:page_size => 'A4', :page_layout => :portrait)
        @docs.each do |doc|
           doc.to_pdf.render_pdf_text(final_pdf)
           final_pdf.start_new_page unless doc == @docs.last 
        end
        final_pdf.number_pages("page <page>/<total>",
        { :at => [final_pdf.bounds.right - 150, 0],:width => 150,
               :align => :right, :start_count_at => 1 })
        send_data final_pdf.render
      }
    end
  end

  # l'action show montre la construction de la sheet en détaillant pour chaque rubrique
  # les comptes qui ont contribué au calcul
  #
  def show
    
    @sheet = @nomenclature.sheet(params[:id].to_sym)

    if @sheet && @sheet.valid?

      respond_to do |format|
        format.html 
        format.csv { send_data @sheet.to_csv  } 
        format.xls { send_data @sheet.to_xls }
        format.pdf { send_data @sheet.to_detailed_pdf.render}
      end
      else
      flash[:alert] = "Le document demandé (#{params[:id].capitalize}) n'a pas été trouvé " unless @sheet
      flash[:alert] = "Le document demandé (#{params[:id].capitalize}) comporte des erreurs : #{@sheet.errors.full_messages.join('; ')}"
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
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:resultat],
    :title=>'Compte de Résultats')
  end

  def liasse
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:actif, :passif, :resultat, :benevolat],
    :title=>'Liasse complète')
  end

  # pluriel volontaire pour le distinguer de show/benvolat qui montre le détail de la page benevolat
  # tandis qu'ici on veut l'action index, mais avec une collection d'un seul élément
  # ce qui perturbe le routage
  # Ici avec sheets/benevolats, on est bien différent de sheets/benevolat qui est routée sur show
  def benevolats
    redirect_to compta_period_sheets_url(:period_id=>@period.id, :collection=>[:benevolat], :title=>'Bénévolat')
  end


  # dernière action de ce controller, detail donne les valeurs des comptes pour l'ensemble des 
  # comptes avec leur rattachement aux rubrik adéquates.
  # c'est une sorte de balance mais en fin d'exercice et avec les comptes de l'exercice mais 
  # aussi de l'exercice précédent
  def detail 
    @detail_lines = @period.two_period_account_numbers.map  {|num| Compta::RubrikLine.new(@period, :actif, num)}
    respond_to do |format|  
        format.html
        format.csv { send_data @detail_lines.inject('') {|i, line|  i += line.to_csv  } } 
        format.xls { send_data(@detail_lines.inject('') {|i, line|  i += line.to_xls  }, :filename=>'detail.csv')   }
        format.pdf {
            pdf = PdfDocument::Base.new(@detail_lines, {:title=>'Détail des comptes', :columns=>[:select_num, :title, :net, :previous_net],
              :columns_titles=>['Numéro', 'Libellé', 'Montant', 'Ex Précédent']}) do |p|
                 p.columns_widths = [15,45,20,20]
                 p.columns_alignements = [:left, :left, :right, :right]
                 p.top_left = "#{@organism.title}\n#{@period.exercice}" 
                 p.stamp = @period.closed? ? '' : 'Provisoire' 
              end
            send_data pdf.render
        }
      end
  end

  protected

  # appelé par before_filter pour s'assurer que la nomenclature est valide
  def check_nomenclature
    @nomenclature = @period.nomenclature
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

