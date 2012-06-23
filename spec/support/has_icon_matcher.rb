


 module Capybara::Node::Matchers

      # has_icon? est un ajout aux matchers de capybara et permet de tester
      # si une icone est présente avec un line
      # s'appelle avec le nom en minuscule de l'icone
      # l'option href permet de vérifier que le lien est correct
      # par exemple : page.find('tbody tr:first td:last').should have_icon('afficher', href:'/bank_extracts')
      #
      # L'icone est par convention dans le répertoire assets/icones/....png

   # TODO le href devrait être recherché spécificiquement dans le scope du a
   # pour être sur que l'image et le href sont associés

   def has_icon?(alt, options = {})
        source = "/assets/icones/#{alt}.png"
        locator = ".//img[@src='#{source}']"
        result =  has_selector?(:xpath, locator, options)
          #puts self.inspect if result == false
        if options[:href] && result
          result = has_selector?(:xpath, ".//a[@href='#{options[:href]}']") unless options[:href] == nil
          #puts self.inspect if result == false
        end
        result
      end
    end