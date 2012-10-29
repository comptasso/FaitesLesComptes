# coding: utf-8

class Array

  # permet d'ajouter les valeurs de deux tableaux
  # fait un test sur les valeurs pour éviter que nil crée des problèmes
  def cumul(other)
    r = []
    self.each_with_index {|v, i| r[i] = other[i] ?  v : v + other[i]}
    r
  end

end

