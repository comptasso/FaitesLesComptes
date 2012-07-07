# coding: utf-8
#lib/month_year.rb

require 'date'

class MonthYear
  include Comparable

  attr_reader :year, :month

  def initialize(h)
    @date = Date.civil(h[:year].to_i, h[:month].to_i)  # pour généréer InvalidDate si les arguments sont non valables
    @month = '%02d' % h[:month]
    @year = '%04d' % h[:year]
  end

  def to_s
    [@month.to_s, @year.to_s].join('-')
  end

  def to_format(format)
    I18n.l( @date, :format=>format)
  end

  def to_short
    to_format('%b')
  end

  def self.from_date(date)
    MonthYear.new(year:date.year, month:date.month)
  end

  def <=>(other)
    comparable_string <=> other.comparable_string
  end

  def comparable_string
    (@year+@month).to_i 
  end

  def beginning_of_month
    @date.beginning_of_month
  end

  def end_of_month
    @date.end_of_month
  end

  def to_french_h
    {an:@year, mois:@month}
  end

 

end
