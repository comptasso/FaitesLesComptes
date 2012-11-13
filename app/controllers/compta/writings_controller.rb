# -*- encoding : utf-8 -*-

class Compta::WritingsController < Compta::ApplicationController

  before_filter :find_book
  before_filter :fix_date, :only=>:new

  # GET /writings
  # GET /writings.json
  def index
    @writings = @book.writings.period(@period).all
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
    @writing = @book.writings.new(date: @d)
    if flash[:previous_writing_id]
      @previous_writing = Writing.find_by_id(flash[:previous_writing_id])
    end
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

  # POST lock
  # action qui verrouille l'écriture
  def lock
    @writing = Writing.find(params[:id])
    @writing.lock
    redirect_to compta_book_writings_url(@book)
  end

  def all_lock

    @book.writings.period(@period).unlocked.each {|w| w.lock}
    redirect_to compta_book_writings_url(@book)
  end

  # POST /writings
  # POST /writings.json
  def create
    params[:writing][:date_picker] ||=  l(@period.start_date)
    @writing = @book.writings.new(params[:writing])

    respond_to do |format|
      if @writing.save
        flash[:date]=@writing.date # permet de transmettre la date à l'écriture suivante
        flash[:previous_writing_id]=@writing.id
        format.html {
          if @book.type == 'AnBook'
            redirect_to compta_book_writings_url(@book)
          else
            redirect_to new_compta_book_writing_url(@book)
          end
           }
      else
        flash[:alert]= @writing.errors.messages
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
        format.html { redirect_to compta_book_writing_url(@book, @writing), notice: 'Ecritue mise à jour.' }
      
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

  def fix_date
    @d = flash[:date]
    @d = @period.start_date if @book.type == 'AnBook'
  end
end
