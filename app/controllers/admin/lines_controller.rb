# -*- encoding : utf-8 -*-

class Admin::LinesController < Admin::ApplicationController

  def index
    if params[:status]=='open'
      @lines=@period.lines.where('locked IS ?', false).all
    else
      flash[:notice]="Pas de lignes à afficher"
    end
  end

end
