class Book < ActiveRecord::Base

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  
  belongs_to :organism
  has_many :lines, dependent: :destroy
  attr_reader :monthly_graph
  
  validates :title, presence: true


  def prepare_graph(period)
    @monthly_graph = Utilities::BookGraph.new(self,period)
  end



end
