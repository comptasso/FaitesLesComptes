# coding: utf-8

class SessionsController < ApplicationController

  skip_before_filter :log_in?, :only => [:new, :create]
  skip_before_filter :find_organism, :current_period


  def new
    session[:user] = session[:org_db] = session[:period]= nil
    @user = User.new
  end

  def create
    @user = User.find_by_name(params[:user][:name])
    if @user  # l'utilisateur est connu
      session[:user] = @user.id
      # réorientation automatique selon le nombre de rooms
      case @user.rooms.count
      when 0 then redirect_to new_admin_organism_url and return
      when 1
          redirect_to room_url(@user.enter_first_room) and return
      else
          logger.debug 'passage par sessions_controller et plusieurs organismes'
          redirect_to admin_organisms_url and return
      end

    else
      link = %Q[<a href="#{new_admin_user_url(params[:user])}">Nouvel utilisateur</a>]
      flash[:alert] = "Cet utilisateur est inconnu. Si vous voulez vraiment créer un nouvel utilisateur, cliquez ici : #{link}. \n
      Sinon, saisissez le bon nom dans la zone ci-dessous".html_safe
      @user = User.new(params[:user])
      render 'new'
    end
  end

  def destroy
    session[:user] = session[:org_db] = session[:period]= nil
  end


end