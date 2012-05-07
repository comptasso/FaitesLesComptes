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
module Utilities::PickDateExtension

  def self.included(base)
    base.extend ClassMethods
  end


  module ClassMethods
    # définition de la méthode de classe pick_date_for
    # laquelle définit une série de méthode getter et setter
    def  pick_date_for(*args)
      args.each do |arg|
        # definition de arg_picker
        send :define_method, "#{arg.to_s}_picker" do(arg)
          value = self.send(arg)
          value ? (I18n::l value) : nil
        end

        # definition de arg_picker=
        send :define_method, "#{arg.to_s}_picker=" do |value|
          s  = value.split('/')
          date = Date.civil(*s.reverse.map{|e| e.to_i}) rescue nil
          if date
            self.send("#{arg.to_s}=", date)
          else
            raise ArgumentError, 'string cant be transformed to a date'
          end
        end
      end
    
    end
  end

end


