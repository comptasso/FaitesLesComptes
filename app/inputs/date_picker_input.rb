
# la classe DatePickerInput permet d'avoir un champ de saisie de date avec
# un widget qui permet de sélectionner la date.
# Le widget vient de jQueryUI et réagit aux champs ayant la classe input_date_picker
# Un fichier css permet d'afficher un petit calendrier dans le champ de saisie.
# Les champs data-min et date-max sont à fournir et servent de limite au widget
# La méthode input transforme ces valeurs en un format lisible par javascript.
#
class DatePickerInput < SimpleForm::Inputs::Base

 def input
   input_html_options['data-jcmin'] = input_html_options[:date_min].to_formatted_s(:date_picker)
   input_html_options['data-jcmax'] = input_html_options[:date_max].to_formatted_s(:date_picker)
   input_html_classes.unshift('input_date_picker')
   
   input_html_options.delete :date_min
   input_html_options.delete :date_max

    @builder.text_field(attribute_name, input_html_options)
  end
end


