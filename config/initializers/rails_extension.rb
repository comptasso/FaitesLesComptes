# coding: utf-8


# cette extension est destinée à permettre à rails de trouver la table
# pour des modèles qui sont dans des namespace différent.
# En l'occurence Compta::Balance qui correspond à la table compta_balance
ActiveRecord::Base.class_eval do
  def self.table_name
    name.split("::").map { |package| package.underscore.pluralize }.join("_")
  end
end


