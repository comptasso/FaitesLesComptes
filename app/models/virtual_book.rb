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
# Cet attribut doit être rempli par la partie appelante
# 
# TODO voir si on ne pourrait pas utiliser les possibilités de has_many virtual_books dans la modèle organisme
# pour y rajouter un callback de création.
# 
# sold_at est surchargé pour fonctionner selon le mode recettes dépenses
# monthly_value, utilisé pour les graphes est surchargé pour avoir un graphe en ligne
# et donc en cumul.
#
# pave_char (également surchargé) permet d'indiquer le type de graphique que l'on souhaite pour l'affichage du DashBoard
#
# Les virtual_books se créent par la méthode Organism#virtual_books définie par un has_many dans la classe Organism
#
# En pratique, Organism propose les méthodes cash_books et bank_books pour retourner une collection de virtual books.
#
class VirtualBook < Book

  attr_accessor :virtual

  belongs_to :organism

  def lines
    virtual.compta_lines
  end

  # renvoie les charactéristique du pavé, en l'occurence la racine du partial et 
  # la classe à utiliser pour le pavé.
  #
  # Cela peut donc être ['cash_pave', 'cash_book'] ou  ['bank_account_pave', 'bank_account_book']
  #
  # TODO : en fait cela relève de la responsabilité d'une classe pavé
  #
  def pave_char
    vcu = virtual_class.name.underscore
    [vcu + '_pave', vcu + '_book']
  end
  
  # surcharge de cumulated_at pour avoir toutes les méthodes de sold
  def cumulated_at(date = Date.today, dc)
    -virtual.cumulated_at(date, dc)
  end

  # dans les caisses et comptes bancaires, on affiche les soldes
  # TODO je pense que ce n'est pas de la responsabilité de cette classe de ne rien retourner si date future
  # voir à mettre cette subtilité dans la classe appelante.
  def monthly_value(selector)
    if selector.is_a?(String)
      selector = Date.civil(selector[/\d{4}$/].to_i, selector[/^\d{2}/].to_i,1)
    end
    # on arrête la courbe au mois en cours
    return sold_at(selector.end_of_month)  unless selector.beginning_of_month.future?
  end


  protected

  # virtual peut être une instance de cashAccount ou de Cash ou de BankAccount
  #
  # virtual class renvoie donc cash ou cash_account.
  # Utilisé par les pavés pour h
  def virtual_class
    virtual.class
  end

end
