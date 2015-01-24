# -*- encoding : utf-8 -*-

# l'objet de ce module est de faciliter la création de boîtes modales 
module ModalsHelper
  
  # crée les différents tags (modal-dialog, modal-content, modal-header)
  # demandés par bootstrap pour une boite modale
  def modal_form(title, id, partial)
    content_tag :div, {'class'=>['modal', 'fade'], id:id,  tabindex:'-1',
      role:'dialog', 'aria-labelledby'=>title, 'aria-hidden'=>'true'} do
      content_tag :div, 'class'=>'modal-dialog', id:"#{id}_dialog" do
        content_tag :div, 'class'=>'modal-content' do
          
          inter = content_tag :div, 'class'=>'modal-header' do
            tete = content_tag :button, {'class'=>'close', 'data-dismiss'=>'modal', 'aria-hidden'=>'true'} do
              'x'
            end 
            tete += content_tag :h3 do 
              title
            end
            tete
          end 
          inter += render partial:partial
          inter
        end
      end
    end
  end
end
