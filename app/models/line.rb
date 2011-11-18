class Line < ActiveRecord::Base
  belongs_to :listing
  belongs_to :destination
  belongs_to :nature

  default_scope order: 'line_date ASC'

#  def debit
#    debit.printf('%.2f', self.debit)
#  end
end
