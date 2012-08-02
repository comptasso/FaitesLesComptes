# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end


# surcharge de ordinalize pour avoir 1er (par exemple 1er janvier)
module ActiveSupport
  module Inflector
    def ordinalize(number)
      if number.to_i == 1
        '1er'
      else
        "#{number}"
      end
    end

  end
end
