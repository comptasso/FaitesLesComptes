# coding: utf-8


# Ce validator trouve les attribut du record qui sont de type Date,
# et s'assure que tous les attributs sont dans la même période
# Il ajoute une erreur à l'ensemble des attributs de type date
# Cette erreur peut être : pas d'exercice
# les x dates de cet enregistrement doivent être dans un même exercice
class SamePeriodValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value # la présence est testée par un autre validator (mais en même
    # temps, il ne faut pas que l'absence de valeur plante le programme
    date_fields = record.class.columns.select {|c| c.type == :date}.map {|c| c.name}
    # on a alors un array du genre 'begin_date', 'end_date'
    o = Organism.first
    p = o.find_period(value)
    unless p
      record.errors[attribute] << "Pas d'exercice pour cette date"
      return
    end
    date_fields.each do |df|
      date = record.send(df)
      if date
        q = o.find_period(date)
        record.errors[df.to_sym] << "Pas dans le même exercice que #{attribute}" if q != p
      end
    end
  end
end
