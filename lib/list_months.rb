# coding: utf-8

require 'month_year'

class ListMonths
  include Enumerable

  def initialize(begin_date, end_date)
    @lm = []
    while begin_date < end_date
    @lm << MonthYear.from_date(begin_date)
    begin_date =  begin_date >> 1
    end
  end

  def to_s
    collect {|m| m.to_s}.join(', ')
  end

  def to_abbr
    to_list('%b')
  end

  def to_abbr_with_year
    to_list('%b %y')
  end
  
  def to_list(format = nil)
    collect {|m| m.to_format(format) }
  end

  def each
    @lm.sort.each {|i| yield i}
  end

end
