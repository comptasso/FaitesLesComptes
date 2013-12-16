# coding: utf-8

require 'pdf_document/base'

# Classe destinée à produire une balance sur deux exercices
# 
# Elle s'initialise avec un period et dispose de deux méthodes
# - to_pdf pour produire un pdf
# - lines qui restitue une collection de RubrikLine
# 
#
class Compta::TwoPeriodsBalance
  def initialize(period)
    @period = period
  end
  
  def lines
    @period.two_period_account_numbers.map  {|num| Compta::RubrikLine.new(@period, :actif, num)}
  end
  
  def to_pdf
    # TODO voir pour utiliser une sous classe de PdfDocument::Base
    # et des constantes pour les largeurs de colonnes
    PdfDocument::Base.new(lines, {title:'Détail des comptes',
            nb_lines_per_page:27,
            columns_methods:[:title, :brut, :amortissement, :net, :previous_net],
            columns_titles:['Libellé', 'Brut', 'Amortissement', 'Net', 'Ex Précédent']}) do |pdf|
          pdf.columns_widths = [48,13,13,13,13]
          pdf.columns_alignements = [:left, :right, :right, :right, :right]
          pdf.organism_name = @period.organism.title
          pdf.exercice = @period.long_exercice
          pdf.subtitle = "Du #{I18n.l @period.start_date} au #{I18n.l @period.close_date}"
          pdf.stamp = @period.closed? ? '' : 'Provisoire' 
        end
  end
  
end