# coding: utf-8

# Construit un nouveau Journal Général et l'affiche

class Compta::SheetsController < Compta::ApplicationController

  def bilan

    a = {}
    a['Fonds Commercial'] = Compta::Rubrik.new(@period, 'Fonds commercial', :actif, ['206', '207', '-297'])
    a['Autres'] = Compta::Rubrik.new(@period, 'Autres',:actif,  ['20', '201', '208'])
    a['Immobilisations corporelles'] = Compta::Rubrik.new(@period, 'Immobilisations corporelles', :actif,  ['21', '23', '-281', '-291'])
    a['Immobilisations financières'] = Compta::Rubrik.new(@period, 'Immobilisations incorporelles', :actif, ['27', '-297'])
    @total1 = Compta::Rubriks.new(@period, 'Total 1', [a['Fonds Commercial'], a['Autres'], a['Immobilisations corporelles'], a['Immobilisations financières']])
    a['mp'] = Compta::Rubrik.new(@period, 'Matières premières, approvisionnements, encours de production',:actif,  ['31', '32', '33', '34', '35', '-391', '-392', '-393', '-394', '-395'])
    a['marchandises'] = Compta::Rubrik.new(@period, 'Marchandises',:actif, [ '37', '-397'])
    a['avances'] =  Compta::Rubrik.new(@period, 'Avances et acomptes sur commandes',:actif,  ['409'])
    a['clients'] = Compta::Rubrik.new(@period, 'Clients et comptes rattachés',:actif,  ['41%'])
    a['autres'] = Compta::Rubrik.new(@period, 'Autres*(3)',:actif,  ['46', '-496'])
    a['valeurs'] = Compta::Rubrik.new(@period, 'Valeurs mobilières de placement',:actif,  ['50'])
    a['dispo'] = Compta::Rubrik.new(@period, 'Disponibilités',:actif,  ['51%', '53%'])
    a['cca'] = Compta::Rubrik.new(@period, 'Charges constatées d\'avance',:actif,  ['486'])
    @total2 = Compta::Rubriks.new(@period, 'Total II',  [a['mp'], a['marchandises'], a['avances'], a['clients'], a['autres'], a['valeurs'], a['dispo'], a['cca']])
    @total_general = Compta::Rubriks.new(@period, 'Total général (I + II)', [@total1, @total2])

    respond_to do |format|
        format.html
        format.pdf  {
          

        }
    end
  end

  def detail
    @detail_lines = @period.two_period_account_numbers.map  {|num| Compta::RubrikLine.new(@period, :actif, num)}
  end

end

