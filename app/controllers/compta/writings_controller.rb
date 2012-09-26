class Compta::WritingsController < Compta::ApplicationController

  before_filter :find_book

  # GET /writings
  # GET /writings.json
  def index
    @writings = @book.writings.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @writings }
    end
  end

  # GET /writings/1
  # GET /writings/1.json
  def show
    @writing = Writing.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @writing }
    end
  end

  # GET /writings/new
  # GET /writings/new.json
  def new
    
    @writing = @book.writings.new
    2.times {@writing.compta_lines.build}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @writing }
    end
  end

  # GET /writings/1/edit
  def edit
    @writing = Writing.find(params[:id])
  end

  # POST /writings
  # POST /writings.json
  def create
    @writing = Writing.new(params[:writing])

    respond_to do |format|
      if @writing.save
        format.html { redirect_to compta_book_writing_url(@book, @writing), notice: 'Writing was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /writings/1
  # PUT /writings/1.json
  def update
    @writing = Writing.find(params[:id])

    respond_to do |format|
      if @writing.update_attributes(params[:writing])
        format.html { redirect_to compta_book_writing_url(@book, @writing), notice: 'Writing was successfully updated.' }
      
      else
        format.html { render action: "edit" }
  
      end
    end
  end

  # DELETE /writings/1
  # DELETE /writings/1.json
  def destroy
    @writing = Writing.find(params[:id])
    @writing.destroy

    respond_to do |format|
      format.html { redirect_to compta_book_writings_url @book}
      
    end
  end

  protected

  def find_book
    @book = Book.find(params[:book_id])
  end
end
