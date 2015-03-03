# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|  
  # config.filter = {wip:true} 
end

describe "compta/writings/index" do  
  include JcCapybara
  
  def compta_line
    ComptaLine.new(debit:100, credit:0) 
  end
  
  before(:each) do
    @b = stub_model(Book, type:'OdBook')
    assign(:period, stub_model(Period, start_date:Date.today.beginning_of_year,
        close_date:Date.today.end_of_year))
    assign(:book, @b)
    view.stub(:current_page?).and_return false
    ComptaLine.any_instance.stub(:account).and_return(double(Account, long_name:'9999 compte de test'))
  end

  describe 'test du corps' do
  
    before(:each) do
      @b = stub_model(Book)
      @a = [
        stub_model(Writing, :book=>@b, date:Date.today),
        stub_model(Writing, :book=>@b, date:Date.today, locked?:true),
        stub_model(Transfer, :book=>@b, date:Date.today),
        stub_model(Transfer, :book=>@b, date:Date.today, locked?:true),
        stub_model(CheckDepositWriting, :book=>@b, date:Date.today)
      ]
      @a.stub(:unlocked).and_return(@a) 
      @a.stub(:not_transfer).and_return(@a)   
      @a.stub(:any?).and_return false   
      assign(:writings,@a)
      
    end

  

    
    it "render une collection avec cinq écritures" do
      render
      page.all('.writing').should have(5).elements
    end
    describe 'la partie content_menu' do
    
      it 'les icones par défaut (nouveau et 3 export)' do
        @b.stub_chain(:writings, :compta_editable, :any?).and_return false
        render
        list_icons = content(:menu).all('a.icon_menu img')
        list_icons.should have(4).icons
        list_icons[0][:src].should == '/assets/icones/nouveau.png'
        list_icons[1][:src].should == '/assets/icones/pdf.png'
        list_icons[2][:src].should == '/assets/icones/table-export.png'
        list_icons[3][:src].should == '/assets/icones/report-excel.png'
      end


      it 'affiche un cadenas de couleur si le livre est un livre OD et écritures verrouillables' do
        @b.stub_chain(:writings, :compta_editable, :any?).and_return true
        assign(:book, @b)
        assign(:mois, 'tous')
        render  
        
        
        list_icons = content(:menu).all('img')
        list_icons.should have(5).elements
        list_icons[4][:src].should == '/assets/icones/verrouiller.png'
    
      end

      it 'n affiche pas le cadenas si le mois n est pas tous' do
        
        assign(:mois, '02')
        render

        list_icons = content(:menu).all('img')
        list_icons.should have(4).elements
      end

    end
    
  end
  
  describe 'les icones des lignes de la table affichée' do
  
    context 'le livre est OD' do
      
          
      it 'chaque writing non verrouillée a 3 actions représentées par des icones' do
        @a = [stub_model(Writing, :book=>@b, locked_at:nil, date:Date.today)]    
        @a.first.stub(:compta_lines).and_return([
            compta_line, compta_line
          ])
        assign(:writings,@a)
        render
        fra = page.find('.writing').all('.title img')
        fra.should have(3).icons # les icones pour modifier, effacer et verrouiller
        fra[0][:src].should == '/assets/icones/modifier.png'
        fra[1][:src].should == '/assets/icones/supprimer.png'
        fra[2][:src].should == '/assets/icones/verrouiller.png'
      end

      it 'la deuxième écriture, verrouillée, ne propose pas de lien' do
        @a = [stub_model(Writing, :book=>@b, locked_at:Time.now, date:Date.today)] 
        @a.first.stub(:compta_lines).and_return([
            compta_line, compta_line
          ])
        assign(:writings,@a)
        render
        page.find('.writing').all('.title img').should have(0).icons
      end

      it 'Une écriture de transfert non verrouillée affiche un cadenas en noir et blanc' do
        @a = [stub_model(Transfer, :book=>@b, locked_at:nil, date:Date.today)] 
        @a.first.stub(:compta_lines).and_return([
            compta_line, compta_line
          ])
        assign(:writings,@a)
        render
        fra = page.find('.writing').all('.title img')
        fra.should have(1).icons
        fra[0][:src].should == '/assets/icones/nb_verrouiller.png'
      end

      it 'un Transfert verrouillé n affiche aucune icône' do
        @a = [stub_model(Transfer, :book=>@b, locked_at:Time.now, date:Date.today)] 
        @a.first.stub(:compta_lines).and_return([
            compta_line, compta_line
          ])
        assign(:writings,@a)
        render
        page.find('.writing').all('.title img').should have(0).icons
      end

      it 'une remise de chèque apparait avec une icone noir et blanc' do
        @a = [stub_model(CheckDepositWriting, :book=>@b, date:Date.today)] 
        @a.first.stub(:compta_lines).and_return([
            compta_line, compta_line
          ])
        assign(:writings,@a)
        render
        fra = page.find('.writing').all('.title img')
        fra.should have(1).icons
        fra[0][:src].should == '/assets/icones/nb_verrouiller.png'
      end
     

     
    end


    context 'le livre n est pas un OD' do

      before(:each) do
        @b.stub(:type).and_return('IncomeBook')
      end

      it 'il n y des icones de verrouillage uniquement mais en noir et blanc' do
        @a = [stub_model(Writing, :book=>@b, date:Date.today)] 
        @a.first.stub(:compta_lines).and_return([
            compta_line, compta_line
          ])
        assign(:writings,@a)
        render
        fra = page.find('.writing').all('.title img')
        fra.should have(1).images 
        fra[0][:src].should == '/assets/icones/nb_verrouiller.png'
        
      end

    end
  
  end
   
end

  
