# coding: utf-8

require 'book.rb'

# un VirtualBook est un modèle non persistent qui représente un livre de caisse ou de banque
# Le virtual_book fonctionne en trésorerie (entrées sorties) et le sold est donc
# inversé par rapport au solde comptable.
#
# Un virtual_book hérite de Book et donc des méthodes Utilities::JcGraphic et
# Utilities::Sold
#
# L'attribut virtual représente la classe sous jacente, donc une caisse ou un compte bancaire
# 
# sold_at est surchargé pour fonctionner le mode recettes dépenses
# monthly_value, utilisé pour les graphes est surchargé pour avoir un graphe en ligne
# et donc en cumul.
#
# pave_char permet d'indiquer le type de graphique que l'on souhaite pour l'affichage du DashBoard
#
class VirtualBook < Book

  attr_accessor :virtual

  belongs_to :organism

  def lines
    virtual.compta_lines
  end

  # renvoie les charactéristique du pavé, en l'occurence la racine du partial et 
  # la classe à utiliser pour le pavé
  def pave_char
    vcu = virtual_class.name.underscore
    [vcu + '_pave', vcu + '_book']
  end

  # virtual peut être une instance de BankAccount ou de Cash
  #
  # virtual class renvoie donc cash ou bank_account
  def virtual_class
    virtual.class
  end

  def cumulated_at(date = Date.today, dc)
    -virtual.cumulated_at(date, dc)
  end



  def monthly_value(selector)
    if selector.is_a?(String)
      selector = Date.civil(selector[/\d{4}$/].to_i, selector[/^\d{2}/].to_i,1)
    end
    # on arrête la courbe au mois en cours
    return sold_at(selector.end_of_month)  unless selector.beginning_of_month.future?
  end

end
