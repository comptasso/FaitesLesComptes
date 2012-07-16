# coding: utf-8

module Stats

# un listing est composé de une ou plusieurs pages chacune ayant des lignes.
# Dans un listing, la première page n'a pas de report, les autres pages en ont
# Chaque page affiche le total de la page
# ainsi que le à reporter
# la dernière page n'affiche pas 'à reporter', mais 'total général'
#
# Le listing se crée à partir d'un array ligne de titre (qui sera répété sur chaque page)
# et d'un array de lignes
#


class Listing

  attr_reader :lines
  attr_accessor :nb_per_page

  def initialize(title_line, stat_lines)
    @lines = stat_lines
    @nb_per_page = 22 # valeur par défaut
    @title_line = title_line
  end

  # construit une collection de Stats::Pages, chacune ayant un nombre de ligne
  # égale à nb_per_page (sauf la dernière bien entendu)
  def pages
    return @pages if @pages
    nb_page = 1 + (@lines.size/@nb_per_page) 
    @pages = 0.upto(nb_page-1).collect do |i|
       Stats::Page.new(i+1, @title_line, @lines[(i*@nb_per_page)..(@nb_per_page*(i+1)-1)])
    end
     # initialise les reports (la première page n'a pas de report)
     1.upto(nb_page-1) do |i|
       @pages[i].report_values = @pages[i-1].to_report_values
     end
     # on indique à p[nb_page - 1] que c'est la dernière page
     @pages[nb_page - 1].is_last
     @pages
  end

  def page_number(i)
    pages[i-1]
  end

  def nb_pages
    pages.size
  end

  def each_page(&block)
    pages.each {|p| yield p}
  end
  
end


end

