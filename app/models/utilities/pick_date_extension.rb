# coding: utf-8

# l'idée de ce module est d'étendre les capacités de la classe ActiveRecord::Base
# pour avoir des arguments virtuels de type pick_date
# La déclaration se fait en appelant pick_date_for avec un argument du modèle de type date.
# Exemple pick_date_for :line_date
#
# Ce qui définit deux méthodes
# line_date_picker=
# et line_date_picker
#
# Chacune de ces méthodes servent alors d'attribut virtuel pour transformer les dates
# au format ruby en string au format jj/mm/aaaa
#
#
#  # argument virtuel pour la saisie des dates
#  def pick_date
#    date ? (I18n::l date) : nil
#  end
#
#  def pick_date=(string)
#    s = string.split('/')
#    self.date = Date.civil(*s.reverse.map{|e| e.to_i})
#  rescue ArgumentError
#    self.errors[:date] << 'Date invalide'
#    nil
#  end
#


module Utilities::PickDateExtension

   def  self.pick_date_for(*args)

    #    code = ''
    #    code << "def #{fn_name}; #{arg} ? (I18n.l #{arg}) : nil; end\n"
    args.each do |arg|
      fn_name = arg.to_s + '_picker'
      send :define_method, fn_name do(arg)
        value = self.send(arg)
        value ? (I18n::l value) : nil
      end

      fn_name = fn_name + '='
      send :define_method, fn_name do |value|
        s  = value.split('/')
        date = Date.civil(*s.reverse.map{|e| e.to_i}) rescue nil
        if date
          m_name = arg.to_s + '='
          self.send(m_name, date)
        end
      end
    end
    #    class_eval code
  end

end


