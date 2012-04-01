# -*- encoding : utf-8 -*-

module ApplicationHelper
  # icon_to s'utilise comme link_to mais prend
  # en argument le nom d'un fichier placé dans le sous répertorie icones/
  # icon_to construit l'image_tag avec le nom sans l'extension comme propriété alt et
  # la même chose comme balise title pour le lien.
  #
  def icon_to(icon_file, options={}, html_options={})
    raise ArgumentError unless icon_file
    title=alt= icon_file.split('.')[0].capitalize
    html_options[:title] ||=title
    html_options[:class] ||= 'icon_menu'
    # html_options[:tabindex]= "-1"
    img_path="icones/#{icon_file}"
    link_to image_tag(img_path, :alt=> alt), options, html_options
  end

 def two_decimals(montant)
    sprintf('%0.02f',montant)
  rescue
    '0.00'
  end

 def picker_date(field,date_min,date_max,value=Date.today)
   # TODO traiter le cas d'une date non valable
   content_tag(:span, :class=>"picker_date") do
    text_field_tag(field,{},
      {'data-jcmin'=>"#{date_min.to_formatted_s(:date_picker)}",
      'data-jcmax'=>"#{date_max.to_formatted_s(:date_picker)}",
      :class=>'input_date span2', :value=>value.to_formatted_s(:date_picker)}) 
   end
  end

 def header_organism
   content_tag(:div, class: "span4", id: "organism") do
      if (@organism && !@organism.new_record?)
         html = []
         html << content_tag(:p) {link_to(sanitize(@organism.title), @organism )}
         html << content_tag(:p, :class=> "description") do
             @period.exercice unless @period.nil?
         end
         html.join('').html_safe
      end
   end
 end

 def header_title
   if @organism && @organism.title
   html = sanitize(@organism.title)
   html += " : #{@period.exercice}" unless @period.nil?
   else
     html="Faites les comptes"
   end
   html
 end

 def debit_credit(montant)
    if montant > -0.01 && montant < 0.01
      '-'
    else
      number_with_precision(montant, :precision=> 2)
    end
  rescue
    ''
  end

 
end
