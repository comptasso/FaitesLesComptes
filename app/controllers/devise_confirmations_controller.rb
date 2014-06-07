
# Création d'un controller spécifique qui reprend pratiquement tout la logique 
# de l'original mais ne demande pas à l'utilisateur confirmé de s'enregistrer
# et renvoie directement sur la création d'un organisme
class DeviseConfirmationsController < Devise::ConfirmationsController
  
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty? 
      # les 4 lignes modifiées sont ici
      UserInscription.welcome_user(resource).deliver
      sign_in(resource_name, resource)
      flash[:notice] = premier_accueil
      redirect_to new_admin_room_url
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end
  
  protected
  
  
  # Message de bienvenue pour un utilisateur qui n'a encore créé aucune 
    # Room
    def premier_accueil
      accueil = "Félicitations, votre inscription est confirmée !"
      accueil += "<br/>La première chose à faire est de créer un organisme "
      accueil += "<br/>Vous pouvez aussi <a href=#{bottom_manuals_url}>consulter maintenant les manuels</a> du logiciel
      <br/>ou le faire plus tard; un lien vers les manuels est disponible au bas de chaque page"
      accueil.html_safe
    end
    
end
