class Admin::RoomsController < Admin::ApplicationController

  skip_before_filter :find_organism
  before_filter :use_main_connection

  def index
    @rooms = current_user.rooms
  end

  def new
    @room = current_user.rooms.build
  end

  def create
  end

  def show
    room = current_user.rooms.find(params[:id])
    use_org_connection(room.database_name)
    session[:connection_config] = ActiveRecord::Base.connection_config
    id = Organism.first.id
    redirect_to admin_organism_path(id)
  end

  def update
  end

  def edit
  end

  def destroy
  end
end
