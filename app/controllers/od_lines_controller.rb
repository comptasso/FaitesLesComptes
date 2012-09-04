# coding: utf-8

class OdLinesController < Compta::ApplicationController

def new
  @book=Book.find_by_type('OdBook')
  @min_date = @period.start_date
  @max_date = @period.close_date
  @natures = @period.natures
  @line =  @book.lines.new
end

end
