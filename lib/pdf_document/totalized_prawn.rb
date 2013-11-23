# coding: utf-8

require 'prawn'
require 'pdf_document/simple_prawn'

module PdfDocument
  
  


  # ce modèle par défaut permet d'imprimer un document de plusieurs pages avec des
  # pavés de présentation, ligne de titre, sous-titre, report des valeurs,...
  #
  # Il faut pour cela que le document réponde à certaines méthodes
  # nb_pages : nombre de pages total du document
  # page(n) : retourne la page
  # page.top_left : renvoie le texte du pavé gauche
  # page.title and page.subtitle pour les titres et sous titres du milieu
  # page.top_right : renvoie le texte de droite
  # columns_widths : renvoie la largeur des colonnes en % de la largeur de page
  # page.table_title pour la première ligne de la table
  # page.table_report_line : lignes pour le report
  # page.table_lines : la table des lignes proprement dite
  # page.table_total_line
  # page.table_to_report_line
  class TotalizedPrawn < PdfDocument::SimplePrawn
          
    def fill_pdf(document, numeros = true)

      jclfill_stamp(document.stamp) # on initialise le tampon
      # on démarre la table proprement dite
      # en calculant la largeur des colonnes
      column_widths = document.columns_widths.collect { |w| w*width/100 }
      largeur = width # car après width dans les tables renvoie à une autre largeur
      # la table des pages
      document.pages.each_with_index do |current_page, index|
        
        pad(05) { font_size(12) {entetes(current_page, cursor) } }

        stroke_horizontal_rule

        # une table de une ligne pour les titres
        table [current_page.table_title],
          :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :size=>10, :align=>:center }    do 
          column_widths.each_with_index {|w,i| column(i).width = w}
        end
     #   draw_table_title(current_page) 

      #  draw_table_lines(current_page)

        font_size(8) do


          # une table de une ligne pour le report
          if current_page.table_report_line
            table [current_page.table_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do 
              current_page.total_columns_widths.each_with_index {|w,i| column(i).width = w*largeur/100 }
            end
          end

          # la table des lignes proprement dites
          unless current_page.table_lines.empty?
            table current_page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5],:height => 16,  :overflow=>:truncate} do
              column_widths.each_with_index {|w,i| column(i).width = w}
              document.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
            end
          end


          # la table total et la table a reporter
          table [current_page.table_total_line, current_page.table_to_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
            current_page.total_columns_widths.each_with_index do |w,i|
              column(i).width = largeur*w/100
      
            end
          end

        end
        
        
        stamp 'fond'

        start_new_page unless document.nb_pages == index+1
          

      end
      numerote if numeros
    end
      
  end
  
end