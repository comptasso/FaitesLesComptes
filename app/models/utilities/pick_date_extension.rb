# coding: utf-8

# Ce module étend la classe dans laquelle il est inclus
# pour avoir des arguments virtuels de type pick_date
# La déclaration se fait en appelant pick_date_for avec une liste d'arguments
# du modèle de type date.
# Exemple pick_date_for :begin_date, :end_date
#
# Ce qui définit quatre méthodes
# begin_date_picker et begin_date_picker=
# ainsi que end_date et end_date_picker=
#
# Chacune de ces méthodes servent alors d'attribut virtuel pour transformer les dates
# au format ruby en string au format jj/mm/aaaa
#
# Dans les vues, l'utilisation de ces facilités suppose simple_form_for et
# son extension app/inputs/date_picker_input
#
module Utilities::PickDateExtension

  def self.included(base)
    base.extend ClassMethods
    base.class_eval { alias_method :original_valid?, :valid? }
  end


  module ClassMethods
    # définition de la méthode de classe pick_date_for
    # laquelle définit une série de méthode getter et setter
    def  pick_date_for(*args)

      dup_errors = ''
      args.each do |arg|
        # definition de arg_picker
        send :define_method, "#{arg.to_s}_picker" do 
          value = self.send(arg)
          return value.is_a?(Date) ? (I18n::l value) : instance_eval("@#{arg.to_s}_picker")
        end

        # definition de arg_picker=
        send :define_method, "#{arg.to_s}_picker=" do |value|
          s  = value.split('/') if value
          date = Date.civil(*s.reverse.map{|e| e.to_i}) rescue nil
          if date && date > Date.civil(1900,1,1)
            self.send("#{arg.to_s}=", date)
          else
            instance_eval("@#{arg.to_s}_picker = '#{value}'")
            self.send("#{arg.to_s}=", nil)
            return value
          end
        end

        # on recopie les erreurs de arg vers ceux de arg_picker. 
        dup_errors << "self.errors[:#{arg}].each {|e| self.errors.add(:#{arg}_picker, e)} if self.errors.has_key?(:#{arg})\n"
        dup_errors << "self.errors.delete(:#{arg}_picker) if self.errors.has_key?(:#{arg}_picker) && !self.errors.has_key?(:#{arg})\n"
      
   end

      class_eval %Q{
        def valid?(context = nil)
          result = original_valid?(context)
          #{dup_errors}
          result
        end
      }
   
    
    end
  end

end

