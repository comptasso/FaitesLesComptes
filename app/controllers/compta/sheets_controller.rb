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

  def index
    @docs = params[:collection].map do |c|
      fol = @nomenclature.folios.find_by_name(c.to_s)
      @nomenclature.sheet(@period, fol)
    end
    
    respond_to do |format|
      send_export_token # pour gérer le spinner lors de la préparation du document
      format.html
      format.csv {
        
        datas = ''
        @docs.each {|doc| datas += doc.to_index_csv } 
        send_data datas, :filename=>"#{params[:title] || params[:collection]}.csv"
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
        send_data final_pdf.render,  :filename=>"#{params[:title] || params[:collection]}.pdf"
      }
    end
  end

  # l'action show montre la construction de la sheet en détaillant pour chaque rubrique
  # les comptes qui ont contribué au calcul
  #
  def show
    folio = @nomenclature.folios.find(params[:id])
    @sheet = @nomenclature.sheet(@period, folio)
    
    
    
    if @sheet && @sheet.valid?

      respond_to do |format|
        send_export_token # pour gérer le spinner lors de la préparation du document
        format.html {@rubriks = @sheet.to_html}
        format.csv { send_data @sheet.to_csv  } 
        format.xls { send_data @sheet.to_xls }
        format.pdf { send_data @sheet.to_detailed_pdf.render}
      end
      else
      flash[:alert] = "Le document demandé n'a pas été trouvé " unless @sheet
      flash[:alert] = "Le document demandé comporte des erreurs : #{@sheet.errors.full_messages.join('; ')}"
      redirect_to compta_nomenclature_url # affiche la liste des folios de la nomenclature
      # TODO gagnerait éventuellement à être un folios_controller et une vue index
    end
  end

  # bilans est une action accessoire qui renvoie vers index avec actif et passif comme 
  # paramètres de collection
  def bilans
    redirect_to compta_sheets_url(:collection=>[:actif, :passif], :title=>'Bilan')
  end

  # resultats renvoie vers index avec exploitation, financier et exceptionnel
  def resultats
    redirect_to compta_sheets_url(:collection=>[:resultat],
    :title=>'Compte de Résultats')
  end

  def liasse
    redirect_to compta_sheets_url(:collection=>[:actif, :passif, :resultat, :benevolat],
    :title=>'Liasse complète')
  end

  # pluriel volontaire pour le distinguer de show/benvolat qui montre le détail de la page benevolat
  # tandis qu'ici on veut l'action index, mais avec une collection d'un seul élément
  # ce qui perturbe le routage
  # Ici avec sheets/benevolats, on est bien différent de sheets/benevolat qui est routée sur show
  def benevolats
    redirect_to compta_sheets_url(:collection=>[:benevolat], :title=>'Bénévolat')
  end


  # dernière action de ce controller, detail donne les valeurs des comptes pour l'ensemble des 
  # comptes avec leur rattachement aux rubrik adéquates.
  # c'est une sorte de balance mais en fin d'exercice et avec les comptes de l'exercice mais 
  # aussi de l'exercice précédent
  def detail 
    @detail_lines = @period.two_period_account_numbers.map  {|num| Compta::RubrikLine.new(@period, :actif, num)}
    respond_to do |format|  
        format.html
        format.csv { send_data(detail_csv(@detail_lines)  , :filename=>'detail.csv')} 
        format.xls { send_data(detail_csv(@detail_lines).encode("windows-1252"), :filename=>'detail.csv')   }
        format.pdf {
            pdf = PdfDocument::Base.new(@detail_lines, {:title=>'Détail des comptes',
                :columns=>[:select_num, :title, :brut, :amortissement, :net, :previous_net],
              :columns_titles=>['Numéro', 'Libellé', 'Brut', 'Amortissement', 'Net', 'Ex Précédent']}) do |p|
                 p.columns_widths = [10,30,15,15,15,15]
                 p.columns_alignements = [:left, :left, :right, :right, :right, :right]
                 p.top_left = "#{@organism.title}\n#{@period.exercice}" 
                 p.stamp = @period.closed? ? '' : 'Provisoire' 
              end
            send_data pdf.render
        }
      end
  end

  protected

  # appelé par before_filter pour s'assurer que la nomenclature est valide
  # TODO faire un champ de cette validation et le dévalider lorsqu'il y a modification
  # du plan comptable
  def check_nomenclature
    @nomenclature = @organism.nomenclature
    flash[:alert] = collect_errors(@nomenclature) unless @nomenclature.coherent?
  end 
  
  def detail_csv(lines)
    CSV.generate({:col_sep=>"\t"}) do |csv|
      csv << ['Numéro', 'Libellé', 'Brut', 'Amortissement', 'Net', 'Ex. précédent']
      lines.each {|l| csv << [l.select_num, l.title, l.brut, l.amortissement, l.net, l.previous_net] }
    end.gsub('.', ',')
  end

end

