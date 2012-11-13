# coding: utf-8

# Construit un nouveau Journal Général et l'affiche

class Compta::SheetsController < Compta::ApplicationController

  def bilan

    @total_general = Compta::Sheet.new(@period, 'bactif').total_general


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

