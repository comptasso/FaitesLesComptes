# classe destinée à permettre un affichage inline des radio buttons
# bootstrap indique que le label doit avoir la classe radio-inline
# mais simple_form as: radio_buttons donne la classe radio qui ne semble pas
# pouvoir être complétée facilement.
#
# Il suffit maintenant de faire :as=>:inline_radio_buttons
#

class InlineRadioButtonsInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def item_wrapper_class
    "radio-inline"
  end

  # on surcharge également input car @builder.send de radio buttons
  # ne trouve pas la collection_radio_buttons
  def input(wrapper_parameters)
    label_method, value_method = detect_collection_methods

    @builder.send("collection_radio_buttons",
      attribute_name, collection, value_method, label_method,
      input_options, input_html_options, &collection_block_for_nested_boolean_style
    )
  end
end
