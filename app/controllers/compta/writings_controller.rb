class Compta::WritingsController < Compta::ApplicationController
  # GET /writings
  # GET /writings.json
  def index
    @writings = Writing.all

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
    @writing = Writing.new

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
        format.html { redirect_to @writing, notice: 'Writing was successfully created.' }
        format.json { render json: @writing, status: :created, location: @writing }
      else
        format.html { render action: "new" }
        format.json { render json: @writing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /writings/1
  # PUT /writings/1.json
  def update
    @writing = Writing.find(params[:id])

    respond_to do |format|
      if @writing.update_attributes(params[:writing])
        format.html { redirect_to @writing, notice: 'Writing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @writing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /writings/1
  # DELETE /writings/1.json
  def destroy
    @writing = Writing.find(params[:id])
    @writing.destroy

    respond_to do |format|
      format.html { redirect_to writings_url }
      format.json { head :no_content }
    end
  end
end
