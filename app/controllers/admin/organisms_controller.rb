# -*- encoding : utf-8 -*-

class Admin::OrganismsController < Admin::ApplicationController


  class NomenclatureError < StandardError; end


  skip_before_action :find_organism, :current_period, only:[:index, :show, :new]

  before_filter :owner_only, only:[:destroy]
  after_filter :clear_org_cache, only:[:create, :update, :destroy]

  def index
    @organisms = current_user.organisms
  end

  # GET /organisms/1
  # GET /organisms/1.json
  def show
    # @organism et @period sont définis par cet appel
    organism_has_changed?(current_user.organisms.find(params[:id]))
    unless @period
      flash[:alert]= 'Vous devez créer un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end
  end


 # GET /organisms/new
  def new
    redirect to admin_organisms_path unless current_user.allowed_to_create_organism?
    title = current_user.tenants.first.name rescue 'Inconnu'
    @organism = Organism.new(title:title)
  end


  # POST /organisms/1
  def create
    @organism = Organism.new(admin_organism_params)
    if @organism.save
      fill_holder
      session[:org_id] = @organism.id
      redirect_to new_admin_organism_period_path(@organism),
        notice: flash_creation_livres
    else
      flash.now[:alert] = 'Il n\'a pas été possible d\'enregistrer la structure'
      render 'new'
    end
  end

  # GET /organisms/1/edit
  def edit
    @organism = Organism.find(params[:id])
  end

  # PATCH /organisms/1
  # PATCH /organisms/1.json
  def update
    @organism = Organism.find(params[:id])

    respond_to do |format|
      if @organism.update_attributes(admin_organism_params)

        format.html { redirect_to [:admin, @organism], notice: "Modification de l'organisme effectuée" }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end


   # méthode provisoire pour adaptation du plan comptable des CE aux
  # réglement de l'ANC.
  # TODO après un certain temps pour la transformation, à retirer.
  def reset_folios
    @organism = Organism.find(params[:id])
    params.permit(:period_id)
    @period = @organism.periods.find(params[:period_id])
    @organism.send(:reset_folios)
    flash[:notice] = 'La nomenclature des comptes a été reconstruite'
    redirect_to admin_period_accounts_path(@period)
  end

  # détruit la pièce ainsi que la base associée.
  #
  # Le before_filter only_owner instancie @room
  #
  def destroy
    title = @organism.title
    Rails.logger.info "Destruction de la base #{title}  - méthode organisms_controller#destroy}"

    if @organism.destroy
      flash[:notice] =  "L'organisme suivi par la base #{title} a été supprimé".html_safe
      organism_has_changed?
      redirect_to admin_organisms_url
    else
      flash[:alert] = "Une erreur s'est produite; la comptabilité #{title} n'a pas été supprimée"
      redirect_to admin_organism_url(@organism)
    end
  end

  protected

  #TODO faire spec de cette méthode
  def fill_holder
    current_user.holders.create(organism_id:@organism.id, status:'owner')
  end


  def flash_creation_livres
    html = 'Création de l\'organisme effectuée<br />'
    if @organism.status == 'Comité d\'entreprise'
      html += 'Un livre des recettes et un livre des dépenses ont été créés
pour le budget de fonctionnement; de même pour le budget des activités socio_culturelles<br />'
    else
      html += 'Un livre des recettes et un livre des dépenses ont été créés<br />'
    end
    html += 'Il vous faut maintenant créer un exercice pour cet organisme'
    html.html_safe
  end

  # l action destroy ne sont permises que si le current_user est le owner
  def owner_only
    unless current_user == @organism.owner
      flash[:alert] = "Vous ne pouvez executer cette action car vous n'êtes pas le propriétaire de la base"
      redirect_to admin_organisms_url
    end
  end




   private

  def admin_organism_params
    params.require(:organism).permit(:title, :comment, :status, :siren, :postcode)
  end


end
