# -*- encoding : utf-8 -*-

module Importer
  module BelsImportersHelper
    
    
    # affiche explicitement les erreurs rencontrées lors de l'importation
    # plutôt que le message standard 'Des erreurs ont été trouvées'
    #
    # Deux cas sont prévus : une erreur de lecture du fichier CSV 
    # on affiche alors le fait qu'il y eu une erreur lors de la lecture
    # 
    # Ou une erreur lors de l'interpréation des lignes et là on affiche les 
    # erreurs de chacune des lignes. 
    # 
    # Les erreurs de lignes sont rentrées dans :base, les erreurs de lecture 
    # sont rentrées dans :read
    #
    def error_messages(obj)
      read_error_message = obj.errors.messages[:read].first rescue ''
      html = content_tag(:p,
        "Des erreurs ont été trouvées dans le fichier : #{read_error_message}")  
      html += list_base_errors(obj) if read_error_message.blank?
      html
    end
    
    def list_base_errors(obj)
      base_error_messages = obj.errors.messages[:base] || []
       content_tag(:ul) do
        html = ''     
        base_error_messages.each do |e|
          html << content_tag(:li, e)
        end
        html.html_safe
      end.html_safe
    end
    
    
  end
end