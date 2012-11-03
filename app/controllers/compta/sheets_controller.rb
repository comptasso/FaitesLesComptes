# coding: utf-8

# Construit un nouveau Journal Général et l'affiche

class Compta::SheetsController < Compta::ApplicationController

  def new
    @sheet =  Compta::PdfSheet.new(@period)
    respond_to do |format|
        format.pdf  {send_data @sheet.render("lib/pdf_document/prawn_files/balance_sheet.pdf.prawn"),
          filename:"Bilan_#{@organism.title}.pdf"}
    end
  end

end

