# coding: utf-8
require 'options_for_association_select'

module Admin::BankExtrcatsHelper

def status(obj)
  return 'Inconnu' unless obj.respond_to?('locked?')
  obj.locked? ? 'Verrouillé' : 'Non Verrouillé'
end

end