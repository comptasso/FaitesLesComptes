# coding: utf-8

class SessionsController < ApplicationController

  skip_before_filter :log_in?, :only => [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.find_by_name(params[:name])
    if @user  # l'utilisateur est connu
      session[:user] = @user.id
      # réorientation automatique selon le nombre de rooms
      case @user.rooms.count
      when 0 then redirect_to new_admin_user_room_url(@user) and return
      when 1
          @user.enter_first_room
          redirect_to organism_url(@user.active_organism) and return
      else
          redirect_to admin_user_rooms_url(@user) and return
      end

    else
      link = %Q[<a href="#{new_admin_user_url(:name=>params[:name])}">Nouvel utilisateur</a>]
      flash[:alert] = "Cet utilisateur est inconnu. Pour le créer, cliquez sur #{link}".html_safe
      render 'new'
    end




  end

  def destroy

  end


end