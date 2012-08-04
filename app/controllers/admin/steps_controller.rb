class Admin::StepsController < Admin::ApplicationController
  def show
    @step = session[:step] || 1
    if (session[:step_organism_id])
      @organism = Organism.find(session[:step_organism_id])
    else
      @organism = Organism.new
    end
    render layout:'admin/layouts/wizzard'
  end

  def create_organism
    @organism = Organism.new(params[:organism])
    if @organism.valid?
      @organism.save
      session[:step] = 2
      session[:step_organism_id] = @organism.id
      redirect_to admin_step_url
    else
      render 'show'
    end
  end

  def create_period

  end
end
