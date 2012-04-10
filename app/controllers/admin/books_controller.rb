# -*- encoding : utf-8 -*-

class Admin::BooksController < Admin::ApplicationController




  # GET /books
  # GET /books.json
  def index
    @books = @organism.books.all
  end

  
  # GET /books/new
  # GET /books/new.json
  def new
    @book=@organism.books.build
  end

  # GET /books/1/edit
  def edit
    @book = @organism.books.find(params[:id])
  end

  # POST /books
  # POST /books.json
  def create
    # rendu nécessaire par la single table inheritance
    type = params[:book][:book_type]
    params[:book].delete :book_type
    if type == 'IncomeBook'
      @book = @organism.income_books.build(params[:book])
    else # OutcomeBook par défaut
      @book= @organism.outcome_books.build(params[:book])
    end
     respond_to do |format|
      if @book.save
        format.html { redirect_to admin_organism_books_url(@organism), notice: 'Le livre a été crée.' }
        format.json { render json: @book, status: :created, location: @book }
      else
        format.html { render action: "new" }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /books/1
  # PUT /books/1.json
  def update
    @book = @organism.books.find(params[:id])
    
    respond_to do |format|
      if @book.update_attributes(params[:book])
        format.html { redirect_to admin_organism_books_url(@organism) , notice: 'Le livre a bien été mis à jour.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book = Book.find(params[:id])
    @book.destroy

    respond_to do |format|
      format.html { redirect_to admin_organism_books_url(@organism) }
      format.json { head :ok }
    end
  end

 
end
