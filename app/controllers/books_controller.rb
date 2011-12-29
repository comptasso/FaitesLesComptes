# -*- encoding : utf-8 -*-

class BooksController < ApplicationController

  before_filter :find_organism, :current_period


  # GET /books
  # GET /books.json
  def index
    @books = @organism.books.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @books }
    end
  end

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
