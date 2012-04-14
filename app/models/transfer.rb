class Transfer < ActiveRecord::Base

  belongs_to :organism
  belongs_to :debitable, :polymorphic=>true
  belongs_to :creditable, :polymorphic=>true

  # argument virtuel pour la saisie des dates
  def pick_date
    date ? (I18n::l date) : nil
  end

  def pick_date=(string)
    s = string.split('/')
    self.date = Date.civil(*s.reverse.map{|e| e.to_i})
  rescue ArgumentError
    self.errors[:date] << 'Date invalide'
    nil
  end
end
