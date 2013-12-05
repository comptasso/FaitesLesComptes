# coding: utf-8

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
    PdfDocument::Base.new(lines, {:title=>'Détail des comptes',
            :columns_methods=>[:select_num, :title, :brut, :amortissement, :net, :previous_net],
            :columns_titles=>['Numéro', 'Libellé', 'Brut', 'Amortissement', 'Net', 'Ex Précédent']}) do |pdf|
          pdf.columns_widths = [10,30,15,15,15,15]
          pdf.columns_alignements = [:left, :left, :right, :right, :right, :right]
          pdf.top_left = "#{@period.organism.title}\n#{@period.exercice}" 
          pdf.stamp = @period.closed? ? '' : 'Provisoire' 
        end
  end
  
end