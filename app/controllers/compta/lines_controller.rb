# coding: utf-8

class Compta::LinesController < Compta::ApplicationController

def new
  @book=Book.find(params[:book_id])
  @min_date = @period.start_date
  @max_date = @period.close_date
  @natures = @period.natures
  @line =  @book.lines.new
end

end
