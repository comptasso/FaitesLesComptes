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

  # picker_date affiche un widget pour sélectionner une date à partir d'une date
  # correctement formatée, et de limites.
  # appeler cette méthode avec comme dernier argument :disabled=>true permet
  # d'avoir le champ disabled
  def picker_date(field, date_min, date_max,value = Date.today.to_formatted_s(:date_picker), jc_options ={} )
    # TODO traiter le cas d'une date non valable
    html =  {'data-jcmin'=>"#{date_min.to_formatted_s(:date_picker)}",
      'data-jcmax'=>"#{date_max.to_formatted_s(:date_picker)}",
      :class=>'input_date_picker span8', :value=>value}
    html.merge!({:disabled=>'disabled'}) if jc_options[:disabled] == true
  
    content_tag(:span, :class=>"picker_date") do
      text_field_tag(field,{},html)
    end
  end

 

  # utilisé pour donner la classe active ou inactive aux éléments du menu 
  # supérieur (Saisie/consult, Admin, Compta)
  def active_inactive(name)
    if name == 'root'
      res = saisie_consult_namespace?
    else
      res = current_namespace?(name)
    end
    res ? 'active' : 'inactive'
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
      return montant if montant.is_a? String
      if montant > -0.01 && montant < 0.01
        '-'
      else
        number_with_precision(montant, :precision=> 2)
      end
    rescue
      ''
    end

    

    # ordinalize date s'appuie sur ordinalize qui est redéfini dans
    # config/initializers/inflections.rb
    def ordinalize_date(d)
      "#{d.day.ordinalize} #{I18n.l(d, :format=>:month_year)}"
    end


protected

     #détermine si on est dans un namespace (admin ou compta) spécifique
  # Utilisation current_namespace?('admin')
  def current_namespace?(name)
    unless request
      raise "You cannot use helpers that need to determine the current
page unless your view context provides a Request object in a #request method"
    end
    # request_path est par exemple /admin/organisms/9
    request_uri = request.path.slice(1..-1) # on enlève le leading /
    name == request_uri.split('/').first
  end

  # tout ce qui n'est pas admin ou compta est dans la zone saisie/consult
  def saisie_consult_namespace?
    !(current_namespace?('admin') || current_namespace?('compta'))
  end

  def current_user?
    session[:user]
  end


 
  end
