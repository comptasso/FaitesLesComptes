#coding: utf-8

module Pdflc
  
  # La classe FlcTrame permet de fournir un tampon de nom 'trame' qui sera
  # ensuite utilisé par le pdf pour rajouter toutes les données répétées sur 
  # chaque page.
  # 
  # Les options obligatoires sont title, organism_name, et exercice
  # En option, on peut fournir un subtitle
  # 
  class FlcTrame
    
    attr_accessor :title, :subtitle, :organism_name, :exercice
        
    def initialize(options = {})
      options.each do |k,v|
        send("#{k}=", v)
      end
      @subtitle ||= '' # pour ne pas risquer de vouloir imprimer des nil
      
      
    end
    
    # Crée un tampon pour le document pdf avec comme nom 'trame'
    # et rempli par la méthode protégée #entetes
    def trame_stamp(pdf)
        pdf.create_stamp("trame") do
          entetes(pdf)
        end
    end
    
    def provisoire_stamp(pdf)
      pdf.create_stamp("provisoire") do
          entetes(pdf)
        end
    end
    
    protected
    
     # les entêtes de pages. 3 bounding_box donnant respectivement la partie gauche
    # de l'entete, celle du milieu et celle de droite
    def entetes(pdf)
      
      width = pdf.bounds.right
      h = pdf.bounds.top
           
      pdf.bounding_box [0, h], :width => 150, :height => 40 do 
        pdf.text top_left 
      end

#      pdf.bounding_box [150, h], :width => width-300, :height => 40 do
#        pdf.font_size(20) { pdf.text title.capitalize, :align=>:center }
#        pdf.text subtitle, :align=>:center if subtitle
#      end

      pdf.bounding_box [width-150, h], :width => 150, :height => 40 do
        pdf.text top_right, :align=>:right
      end

    end
    
    def top_left
      "#{organism_name}\n#{exercice}"
    end
    
     def top_right
      I18n::l(Time.now, :format=>"Edition du\n%e %B %Y\nà %H:%M:%S")
    end
    
     
    
    
  end

end