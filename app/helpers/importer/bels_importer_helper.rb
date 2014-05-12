# -*- encoding : utf-8 -*-

module Importer
  module BelsImporterHelper
    
    
    # affiche explicitement les erreurs rencontrées lors de l'importation
    # plutôt que le message standard 'Des erreurs ont été trouvées'
    def error_messages(obj)
      content_tag(:p, 'Des erreurs ont été trouvées dans le fichier : ') + 
        content_tag(:ul) do
          html = ''     
          obj.errors.full_messages.each do |e|
            html << content_tag(:li, e)
          end
          html.html_safe
        end.html_safe
     end
    
    
  end
end