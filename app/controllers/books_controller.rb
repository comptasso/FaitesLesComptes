# -*- encoding : utf-8 -*-

class BooksController < ApplicationController

 
  # GET /books/1
  # GET /books/1.json
  def show
    @book = @organism.books.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @book }
    end
  end

 
 
end
