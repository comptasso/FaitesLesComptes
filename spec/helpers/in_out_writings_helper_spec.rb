# coding: utf-8

require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the WritingsHelper. For example:
#
# describe WritingsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe InOutWritingsHelper do
  describe 'in_out_line_actions' do
    it 'retourne blank si line n est pas editable' do
      line = stub('editable?'=>false, :writing=>(@w = double(:id=>88)))
      helper.in_out_line_actions(line).should == content_tag(:td, :class=>'icon') {' '}
    end

    it 'retourne un lien vers transfer si c est une écriture de transfert' do
      line = double('editable?'=>true, :writing=>(@w = mock_model(Transfer, :id=>88)))
      helper.in_out_line_actions(line).should match(edit_transfer_path(@w.id))
    end
    
    describe 'Une écriture générée par le module adhérent' do
      before(:each) do
        @m = mock_model(Adherent::Member)
        @line = double('editable?'=>false, 
          :writing=>(@w = mock_model(Adherent::Writing, :bridge_id=>'5', :member=>@m)))
      end
            
      it 'retourne un lien vers le record Payment' do
        helper.in_out_line_actions(@line).should match(adherent.member_payments_path(@m))
      end
      
      
    end
    

    it 'sinon propose des liens vers  l edition et la suppression de  lecriture' do
      line = stub('editable?'=>true, :writing=>(@w = stub(:type=>'Autre', :id=>88, :book_id=>7, :book=>mock_model(Book))))
      helper.in_out_line_actions(line).should match(edit_book_in_out_writing_path(@w.book_id, @w))
      helper.in_out_line_actions(line).should match(book_in_out_writing_path(@w.book, @w))
    end
  end
end
