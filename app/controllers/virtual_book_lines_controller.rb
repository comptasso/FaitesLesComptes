# TODO actuellement, n'est prévu que pour un compte bancaire mais
# pourrait si besoin être utilisé pour une caisse.
# en distinguant si on a un params[cash_id] ou un params[:bank_account_id]

class VirtualBookLinesController < ApplicationController
  before_filter :fill_mois
  
  def index
    @bank_account=BankAccount.find(params[:bank_account_id])
    @virtual_book = @bank_account.virtual_book
    if params[:mois] == 'tous'
      @monthly_extract = Extract::BankAccount.new(@virtual_book, @period)
    else
      @monthly_extract = Extract::MonthlyBankAccount.new(@virtual_book, year:params[:an], month:params[:mois])
    end
    
    
    
    send_export_token # envoie un token pour l'affichage du message Juste un instant 
    # pour les exports
    respond_to do |format|
      format.html
      format.pdf do
        @monthly_extract.delay.render_pdf
        flash[:notice] = 'Fichier en cours de préparation'
        redirect_to :back
#        pdf = @monthly_extract.to_pdf
#        send_data pdf.render, :filename=>export_filename(pdf, :pdf) 
      end
      format.csv { send_data @monthly_extract.to_csv, :filename=>export_filename(@monthly_extract, :csv)   }  # pour éviter le problème des virgules
      format.xls { send_data @monthly_extract.to_xls, :filename=>export_filename(@monthly_extract, :csv)  }
    end
  end
  
  
  
  # méthode expérimentale pour utiliser les actions cachées
  # actuellement la vue affiche création du fichier en cours.
  # 
  # Idée générale : on stocke le fichier dans une table avec différents champs
  # un champ blob pour la page, évidemment un champ organism_id, un champ catégory
  # pour enregistrer le type de documents (voir avec une STI ?), par exemple compte bancaire
  # un champ pdf_able_id et pdf_able_type, ce qui permet de le faire appartenir à un
  # modèle qui serait alors pdf_able.
  # evidemment un timestamp. 
  # 
  # Eventuellement cela permet de vérifier que le fichier est toujours d'actualité si 
  # aucune écriture nouvelle n'a été passée concernant le compte bancaire en question.
  # (mais dans un deuxième temps)
  # 
  # Il faut alors que le job fasse la création du fichier puis quand il est fait 
  # qu'il le sauve dans la base correcte.
  # 
  # Dans le même temps, il faut déclencher un timer qui va sonder régulièrement
  # par une requete ajax si le fichier est prêt. 
  # 
  # On pourrait avoir dans la table User (ou Organisme) un champ qui indique le début du travail
  # , puis la fin et l'id du pdf qui vient d'être généré.
  #  Plutôt une table spécifique ? Ou directement la table sachant qu'on connaît la catégorie
  #  d'objet demandé (par exemple une balance).
  #  
  #  Il faudrait commencer par essayer la logique de ce stockage
  #  
  #  Dans l'immédiat j'ai fait une table exportpdfs et son modèle Exportpdf
  #  avec un seul champ content. (limité à 1 méga). TODO voir à augmenter cette limite si nécessaire
  #  
  #  Dans un premier temps, un seul fichier par organisme. 
  # 
  #
  def export_pdf
    @bank_account=BankAccount.find(params[:bank_account_id])
    @virtual_book = @bank_account.virtual_book
    if params[:mois] == 'tous'
      @monthly_extract = Extract::BankAccount.new(@virtual_book, @period)
    else
      @monthly_extract = Extract::MonthlyBankAccount.new(@virtual_book, year:params[:an], month:params[:mois])
    end
    
    # création du record export_pdf
    
    @monthly_extract.delay.render_pdf
  end

  
  protected
  # on surcharge fill_mois pour gérer le params[:mois] 'tous'
  def fill_mois
    if params[:mois] == 'tous'
      @mois = 'tous'
    else
      super
    end
  end
end
