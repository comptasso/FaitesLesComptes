# This migration comes from adherent (originally 20150321054651)
class AddCommentToPayment < ActiveRecord::Migration
  def change
    add_column :adherent_payments, :comment, :string
  end
end
