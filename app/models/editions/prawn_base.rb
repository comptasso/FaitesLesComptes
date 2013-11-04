

module Editions
  # Editions::PrawnBase hérite de Prawn::Document et est la base des autres Editions::Prawn
  # dont Editions::PrawnSheet pour construire le fichier des bilans ou éléments de la liasse
  # et Editions::PrawnBalance pour construire un fichier balance.
  # 
  # Editions::PrawnBase apporte les méthodes communes comme #entetes pour 
  # remplir la partie haute de la page ou #jc_fill_stamp qui produit le tampon.
  # 
  #
  class PrawnBase < Prawn::Document
    
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

      bounding_box [150, y_position], :width => width-300, :height => 40 do
        font_size(20) { text page.title.capitalize, :align=>:center }
        text page.subtitle, :align=>:center
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

