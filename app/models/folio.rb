class Folio < ActiveRecord::Base
  attr_accessible :name, :title, :sens
  has_many :rubriks
  
  # méthode créant les rubriks de façon récursive à partir d'un hash
  # la clé :numéros n'est remplie que si la valeur n'est pas elle même un Hash
  # 
  # méthode appelée par read_and_fill_rubriks
  def fill_rubriks(hash, parent_id = nil)
     hash.each do |k,v|
        r = self.rubriks.create(:name=>k, :parent_id=>parent_id)
        if v.is_a? Hash
          fill_rubriks(v, r.id)
        else
          r.update_attribute(:numeros, v)
        end
      end
  end
  
  def root
    rubriks.where('parent_id IS NULL').first
  end

end
