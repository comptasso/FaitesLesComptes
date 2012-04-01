# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LinesController do
   include OrganismFixture
  
  before(:all) do
    # méthode définie dans OrganismFixture et 
    # permettant d'avoir les variables d'instances @organism, @period, 
    # income et outcome book ainsi qu'une nature
    create_minimal_organism
    
  end

 describe 'POST create' do
   context "post successful" do
     it 'fill a previous_line_id flash whenline is saved' do
       post :create, :income_book_id=>@ib.id,:pick_date_line=>'01/04/2012',
         :line=>{ :nature_id=>@n.id,    :narration=>'ligne valide', :credit=>25.00, :payment_mode=>'Chèque',
       :bank_account_id=>@ba.id}, commit: 'Créer'
       flash[:previous_line_id].should ==  Line.order('id ASC').last.id
     end   
   end  
 end

   describe 'Get new' do
     it "fill the default values" do
       get :new, income_book_id: @ib.id, mois: 4
  #     assigns[:line].bank_account_id.should == @ba.id
       assigns[:line].should be_an_instance_of(Line)
       assigns[:line].line_date.should == Date.civil(2012,5,1)
       assigns[:line].bank_account_id.should == @ba.id 
     end
   end
end

