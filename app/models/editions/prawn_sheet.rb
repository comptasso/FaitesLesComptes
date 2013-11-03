

module Editions
  # Editions::PrawnSheet hérite de Prawn::Document et dispose 
  # de méthodes permettant de produire un fichier pdf pour un folio de type 
  # actif (donc avec 4 colonnes : brut, amort net et previous net) ou de type passif
  # (avec deux colonnes).
  # 
  # L'intérêt de cette classe est de regrouper des méthodes comme #entetes pour 
  # remplir la partie haute de la page ou #jc_fill_stamp qui produit le tampon.
  # 
  # Les méthodes publiques sont fill_actif_pdf et fill_passif_pdf qui fournit les deux
  # types de documents. 
  #
  class PrawnSheet < Prawn::Document
    
    
     
    # construit une page complète d'actif avec entêtes, tampon, titre de la table
    # toutes les lignes
    def fill_actif_pdf(document)
      
      page = document.page(1)
      entetes(page, cursor)
      
      monpdf = self
      jclfill_stamp(document.stamp)
      column_widths = [40, 15, 15, 15, 15].collect { |w| width*w/100 }
      titles = [['', '', '', document.exercice, 'Précédent'], ['', 'Montant brut', "Amortisst\nProvision", 'Montant net', 'Montant net']]
      
      move_down 50
      # la table des lignes proprement dites
      table(titles + page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate}) do
        column_widths.each_with_index {|w,i| column(i).width = w}
        [:left, :right, :right, :right, :right].each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
        # ici, on modifie le style des colonnes en fonction de la profondeur de l'objet
        # si c'est une rubrique de profondeur 0 ou 1 ou 2 (a priori des totaux ou sous-totaux, alors gras),
        # si c'est supérieur à 2 on reste en normal
        # si c'est -1, c'est que c'est un compte et donc en italique
    
        page.table_lines_depth.each_with_index do |d,i|
          row(i+2).font_style = monpdf.style(d) 

        end

      end
      
      stamp "fond"
    end
    
    # construit une page complète de passif avec entêtes, tampon, titre de la table
    # toutes les lignes
    def fill_passif_pdf(document)
      jclfill_stamp(document.stamp)
      page = document.page(1)
      entetes(page, cursor)
         
      column_widths = [70, 15, 15].collect { |w| width*w/100 }
      titles = [['', document.exercice, 'Précédent']]
     
      move_down 50
      monpdf = self
      # la table des lignes proprement dites
      table(titles + page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate}) do
        column_widths.each_with_index {|w,i| column(i).width = w}
        [:left, :right, :right].each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
        # ici, on modifie le style des colonnes en fonction de la profondeur de l'objet
        # si c'est une rubrique de profondeur 0 ou 1 ou 2 (a priori des totaux ou sous-totaux, alors gras),
        # si c'est supérieur à 2 on reste en normal
        # si c'est -1, c'est que c'est un compte et donc en italique
    
        page.table_lines_depth.each_with_index do |d,i|
          row(i+1).font_style = monpdf.style(d) 

        end

      end
      
      stamp "fond"

    end
    
    
  
  
    
  
    # définit le style d'une ligne en fonction de la profondeur de la rubrique
    # pour rappel, depth = -1 pour une ligne de détail de compte
    # sinon depth = 0 pour la rubrique racine puis +1 à chaque fois qu'on 
    # descend dans l'arbre des rubriques.
    def style(depth)
      return :bold if (depth == 0 || depth == 1 || depth == 2)
      return :italic if depth == -1
    end
    
    
    protected 
    
    
    # la largeur de la page
    def width
      bounds.right
    end
    
    
    
    
    # les entêtes de pages. 3 bounding_box donnant respectivement la partie gauche
    # de l'entete, celle du milieu et celle de droite
    def entetes(page, y_position)
      bounding_box [0, y_position], :width => 150, :height => 40 do
        text page.top_left

      end

      bounding_box [150, y_position], :width => width-200, :height => 40 do
        font_size(20) { text page.title.capitalize, :align=>:center }
        #            text page.subtitle, :align=>:center
      end

      bounding_box [width-150, y_position], :width => 150, :height => 40 do
        text page.top_right, :align=>:right
      end

    end
  
    # Définit une méthode tampon pour le PrawnSheet qui peut ensuite être appelée 
    # par fill_actif_pdf et fill_passif_pdf 
    #
    def jclfill_stamp(text)
      if stamp_dictionary_registry['fond'].nil?
        create_stamp("fond") do
          rotate(65) do
            fill_color "bbbbbbb"
            font_size(120) do
              text_rendering_mode(:stroke) do
                draw_text(text, :at=>[250, -150])
              end
            end
            fill_color "000000"
          end
        end
      end
    end
  
  end
  
end

