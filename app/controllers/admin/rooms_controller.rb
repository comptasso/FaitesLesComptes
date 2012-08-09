class RoomsController < ApplicationController
  def index
    @rooms = current_user.rooms
  end

  def new
    @room = current_user.rooms.build
  end

  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end
end
