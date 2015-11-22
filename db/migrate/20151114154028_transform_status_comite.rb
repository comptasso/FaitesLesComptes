class TransformStatusComite < ActiveRecord::Migration
  # Utilisé pour gérer l'existence de deux plans comptables pour les CE
  # Avant la version 1.14.9 status était Comité d'entreprise qui
  # se transforme en comité 1.
  # Les nouveaux comités ayant ensuite le statut de Comite2
  def up
    Organism.connection.execute("UPDATE organisms SET status = 'Comite1' WHERE status = E'Comité d\\'entreprise'; ")
  end

  # Tous les organismes ayant Comite1 comme statut sont ramenés à
  # Comité d'entreprise
  def down
    Organism.connection.execute("UPDATE organisms SET status = E'Comité d\\'entreprise' WHERE status = 'Comite1'; ")
  end

end
