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
end
