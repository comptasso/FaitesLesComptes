# -*- encoding : utf-8 -*-

class Admin::LinesController < Admin::ApplicationController

  def index
    if params[:status]=='open'
      @lines=@period.lines.where('locked IS ?', false).all
      @count=@lines.size
    else
      flash[:notice]="Pas de lignes à afficher"
    end
  end

  def lock
    @line=Line.find(params[:id])
    @line.update_attribute(:locked,true)
    @count=@period.lines.where('locked IS ?', false).count
    
      respond_to do |format|
        format.html # index.html.erb
        format.js
      end
  
  end

end
