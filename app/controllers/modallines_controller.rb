class ModallinesController < ApplicationController

  def create
    @bank_extract=BankExtract.find(params[:bank_extract_id])
    @bank_account = @bank_extract.bank_account
    @organism = @bank_account.organism


    params[:line][:bank_account_id] = @bank_account.id
    @line = Line.new(params[:line])
    if @line.save
      @lines_to_point = Utilities::NotPointedLines.new(@bank_account)
      respond_to do |format|
        format.js
      end

    else
      respond_to do |format|
        format.js {render :new }
      end
      
    end




  end

end
