# coding: utf-8

# Construit un nouveau Journal Général et l'affiche

class Compta::SheetsController < Compta::ApplicationController

  def bilan
    @option = params[:option]
    @actif  = Compta::Sheet.new(@period, 'bactif', :actif).total_general
    @passif  = Compta::Sheet.new(@period, 'bactif', :passif).total_general
    respond_to do |format|
        format.html {render(@option == 'compact' ? 'bilan' : 'bilan_detail')}
        format.pdf  
    end
  end


  def detail
    @detail_lines = @period.two_period_account_numbers.map  {|num| Compta::RubrikLine.new(@period, :actif, num)}
  end

end

