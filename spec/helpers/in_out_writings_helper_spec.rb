# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  # c.filter = { :wip=>true}
   # c.exclusion_filter = {:js=> true }
end

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
      line = double(:writing=>(@w = double(:id=>88, 'editable?'=>false)))
      helper.in_out_line_actions(line).should == content_tag(:td, :class=>'actions') {' '}
    end

    it 'retourne un lien vers transfer si c est une écriture de transfert' do
      line = double(:writing=>(@w = mock_model(Transfer, :id=>88, 'editable?'=>true)))
      helper.in_out_line_actions(line).should match(edit_transfer_path(@w.id))
    end

    describe 'Une écriture générée par le module adhérent' do
      before(:each) do
        @m = mock_model(Adherent::Member)
        @line = double(:writing=>(@w = mock_model(Adherent::Writing,
              :bridge_id=>'5', :member=>@m, 'editable?'=>false)))
      end

      it 'retourne un lien vers le record Payment' do
        helper.in_out_line_actions(@line).should match(adherent.member_payments_path(@m))
      end


    end


    it 'une InOutWriting propose des liens vers l edition et la suppression de la partie principale ' do
      line = double(:writing=>(@w = mock_model(InOutWriting,
            'editable?'=>true, :id=>88, :book_id=>7, :book=>mock_model(Book))))
      helper.line_actions(line).should match(edit_book_in_out_writing_path(@w.book_id, @w))
      helper.line_actions(line).should match(book_in_out_writing_path(@w.book_id, @w))
    end

    it 'et les autrs, vers la partie compta' do
      line = double(:writing=>(@w = double(:type=>'Autre', 'editable?'=>true, :id=>88, :book_id=>7, :book=>mock_model(Book))))
      helper.line_actions(line).should match(edit_compta_book_writing_path(@w.book_id, @w))
      helper.line_actions(line).should match(compta_book_writing_path(@w.book_id, @w))
    end
  end

  describe 'frontline_actions' do

    describe 'pour un Adherent::Writing' do
      before(:each) do
         @line = double(id:'50',
           writing_type:'Adherent::Writing',
           book_id:1,
           editable?:true,
           adherent_payment_id:3)
      end

      it 'oriente vers le payment de cet adhérent' do
        @line.stub(:member_id).and_return 1
        helper.frontline_actions(@line).
          should match(adherent.member_payment_path(@line.member_id, @line.adherent_payment_id))
      end

      it 'ou affiche un conseil si member_id non présent' do
        @line.stub(:member_id).and_return nil
        helper.frontline_actions(@line).
          should match("<img alt=\"Nb detail\" ")

      end
    end

    context 'editable?, renvoie vers' do

      before(:each) do
         @line = double(id:'50',
           book_id:1,
           editable?:true,
           member_id:1,
           adherent_payment_id:3)
      end

      it 'l action edit transfer si c est un transfert'  do
        @line.stub(:writing_type).and_return 'Transfer'
        helper.frontline_actions(@line).
          should match(edit_transfer_path(@line.id))
      end



      it 'l action edit dans les autres cas' do
        @line.stub(:writing_type).and_return 'Autre'
        helper.frontline_actions(@line).
          should match(edit_book_in_out_writing_path(@line.book_id, @line.id))
      end

      it 'ainsi que l action supprimer' do
        @line.stub(:writing_type).and_return 'Autre'
        helper.frontline_actions(@line).
          should match(book_in_out_writing_path(@line.book_id, @line.id))
      end


    end

    context 'non editable?, affiche des conseils' do

      before(:each) do
        @line = double(id:50,
           editable?:false,
           book_id:1,
           writing_type:'Autre',
          cl_locked:false,
          support_locked:false)

      end

      it 'indique que l écriture est dans une remise de chèque', wip:true do
        @line.stub(:support_check_id).and_return 1
        helper.frontline_actions(@line).
          should match('Chèque inclus dans une remise de chèque,
  le retirer de la remise pour pouvoir l&#39;éditer')
      end

       it 'ou qu elle pointée' do
        @line.stub(:support_check_id).and_return nil
        @line.stub(:bel_id).and_return 2
        helper.frontline_actions(@line).
          should match('Ecriture incluse dans un pointage de compte bancaire,
    le retirer du pointage pour pouvoir l&#39;éditer' )
      end

       it 'ou qu elle est verrouillée' do
         @line.stub(:cl_locked).and_return true
         helper.frontline_actions(@line).
          should match('Ecriture verrouillée, modification impossible')
       end

      it 'ou que son support est verrouillé' do
         @line.stub(:support_locked).and_return true
         helper.frontline_actions(@line).
          should match('Ecriture verrouillée, modification impossible')
       end

    end


  end
end
