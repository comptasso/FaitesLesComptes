# coding: utf-8

require 'month_year'

class ListMonths
  include Enumerable

  def initialize(begin_date, end_date)
    @lm = []
    while begin_date <= end_date
    @lm << MonthYear.from_date(begin_date)
    begin_date =  begin_date >> 1
    end
  end

  def to_s
    @lm.collect {|m| m.to_s}.join(', ')
  end

  def to_abbr
    @lm.collect {|m| m.to_short_month}
  end

  def to_abbr_with_year
    each { |m| m.to_short_month + ' ' + m.year[/\d{2}$/]}
  end

  def each
    @lm.sort.each {|i| yield i}
  end

end
