# -*- encoding : utf-8 -*-

module ApplicationHelper
  # icon_to s'utilise comme link_to mais prend
  # en argument le nom d'un fichier placé dans le sous répertorie icones/
  # icon_to construit l'image_tag avec le nom sans l'extension comme propriété alt et
  # la même chose comme balise title pour le lien.
  #
  def icon_to(icon_file, options={}, html_options={})
    raise ArgumentError unless icon_file
    title = alt = icon_file.split('.')[0].capitalize

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

  
  # utilisé pour donner la classe active ou inactive aux éléments du menu 
  # supérieur (Saisie/consult, Admin, Compta).
  #
  # Le but est que l'espace actuel soit marqué comme actif tandis que les autres sont inactifs
  #
  # Il y a 3 espaces de noms : main (correspondant à saisie/consult), admin et compta
  #
  #
  def active_inactive(name)
    name == space ? 'active' : 'inactive'
  end
  
  

  # Affiche le titre en haut à gauche des vues
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
    return montant if montant.is_a? String
    if montant > -0.01 && montant < 0.01
      '-'
    else
      number_with_precision(montant, :precision=> 2)
    end
  rescue
    ''
  end

  # export_icons permet d'afficher les différentes icones d'export.
  #
  # Dans la vue, on utilise export_icons avec comme argument opt les paramètres dont on a besoin pour
  # permettre au serveur de répondre.
  #
  def export_icons(opt)
    html = icon_to('pdf.png', url_for(opt.merge(:format=>'pdf')), :id=>'icon_pdf')
    html += icon_to('table-export.png', url_for(opt.merge(:format=>'csv')), :id=>'icon_csv', title:'csv', target:'_blank')
    html += icon_to('report-excel.png', url_for(opt.merge(:format=>'xls')), :id=>'icon_xls', title:'xls', target:'_blank')
    html.html_safe
  end

    

  # ordinalize date s'appuie sur ordinalize qui est redéfini dans
  # config/initializers/inflections.rb
  def ordinalize_date(d)
    "#{d.day.ordinalize} #{I18n.l(d, :format=>:month_year)}"
  end


  protected

  # renvoie l'espace dans lequel on est : compta, admin ou main
  # mais ce peut être aussi adherent ou autre prefixe
  def space
    requ = request
    return 'main' unless requ
    # request_path est par exemple /admin/organisms/9
    request_uri = requ.path.slice(1..-1) # on enlève le leading /
    request_uri.split('/').first
   
  end

  

 
end
