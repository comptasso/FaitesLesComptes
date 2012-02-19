module OrganismsHelper
  
  # Forunit à la vue les informations cachées pour construire le graphe
  #
  def result_datas
    content_tag :div, :class=>"datas_for_graph", :id=>"datas_result" do #, style="display: none;"> do
        content_tag :span, :id=>"series_result" do
           @graph_result.legend.join(';')
        end
    end
#  <span id#="months_list_<%= book.id %>">  <%= book.graphic.ticks.join(';') %></span>
#  <span id#="datas_list_<%= book.id %>">  <%= book.graphic.series[1].join(';')  %></span>
#  <span id#="previous_datas_list_<%= book.id %>">  <%= book.graphic.series[0].join(';') %></span>
 #</div>
  end
end
