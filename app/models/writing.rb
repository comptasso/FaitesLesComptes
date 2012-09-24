class Writing < ActiveRecord::Base
  include Utilities::PickDateExtension # apporte les méthodes pick_date_for


  belongs_to :book
  belongs_to :od_book
  has_many :compta_lines, :as=>:owner, :dependent=>:destroy

  accepts_nested_attributes_for :compta_lines, :allow_destroy=>true

  pick_date_for :date
end
