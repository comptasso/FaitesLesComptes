# To change this template, choose Tools | Templates
# and open the template in the editor.

class Exportpdf < ActiveRecord::Base
  
   belongs_to :exportable, :polymorphic=>true
  
  
end
