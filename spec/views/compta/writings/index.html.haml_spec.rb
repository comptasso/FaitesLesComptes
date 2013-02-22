# coding: utf-8

require 'spec_helper'

describe "compta/writings/index" do
  include JcCapybara

  before(:each) do
    @b = stub_model(Book)
    assign(:period, stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year))
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
    assign(:book, @b)
  
  end

  describe 'test du corps' do

    describe 'le corps' do
      it "render une collection avec deux écritures" do
        render
        page.all('.writing').should have(5).elements
      end

    end

  
    context 'le livre est OD' do
      before(:each) do
        @b.stub(:type).and_return('OdBook')
        
        render
      end
      
      it 'chaque writing non verrouillée a 3 actions représentées par des icones' do
        fra = page.all('.writing').first.all('.title img')
        fra.should have(3).icons # les icones pour modifier, effacer et verrouiller
        fra[0][:src].should == '/assets/icones/modifier.png'
        fra[1][:src].should == '/assets/icones/supprimer.png'
        fra[2][:src].should == '/assets/icones/verrouiller.png'
      end

      it 'la deuxième écriture, verrouillée, ne propose pas de lien' do
      fra = page.all('.writing')[1].all('.title img')
      fra.should have(0).icons
    end

      it 'la troisième écriture, Transfert non verrouillé affiche un cadenas en noir et blanc' do
      fra = page.all('.writing')[2].all('.title img')
      fra.should have(1).icons
      fra[0][:src].should == '/assets/icones/nb_verrouiller.png'
    end

    it 'la quatrième écriture, Transfert verrouillé, n affiche aucune icône' do
      fra = page.all('.writing')[3].all('.title img')
      fra.should have(0).icons

    end

      it 'une remise de chèque apparait avec une icone noir et blanc' do
        
        
        fra = page.all('.writing')[4].all('.title img')
        fra.should have(1).icons
        fra[0][:src].should == '/assets/icones/nb_verrouiller.png'
      end
     

     
    end


    context 'le livre n est pas un OD' do

      before(:each) do
        @b.stub(:type).and_return('IncomeBook')
      end

      it 'il n y des icones de verrouillage uniquement mais en noir et blanc' do
        render
        page.all('.title img').should have(3).images # car 3 lignes non verrouillées
        page.all('.title img').each do |i|
          i[:src].should == '/assets/icones/nb_verrouiller.png'
        end
      end

    end
   
  end

  describe 'test de la partie content_menu' do
    
    it 'une seule icone Nouveau si le livre a toutes ses écritures verrouillées' do
      @b.stub_chain(:writings, :unlocked, :any?).and_return false
      render
      list_icons = content(:menu).all('a.icon_menu img')
      list_icons.should have(1).icons
      list_icons[0][:src].should == '/assets/icones/nouveau.png'
    end



    it 'affiche un cadenas noir et blanc dans la partie haute si le livre n est pas un livre dOD' do
      @b.stub_chain(:writings, :unlocked, :any?).and_return true
      @b.stub(:type).and_return('IncomeBook')
      render
      # content(:menu).should == 'bonjour'
      list_icons = content(:menu).all('img')
      list_icons.should have(2).icons
      list_icons[1][:src].should == '/assets/icones/nb_verrouiller.png'
    end

    it 'affiche un cadenas de couleur si le livre est un livre OD et que les écritures furent écrite dans OD manuellement' do
      @b.stub_chain(:writings, :unlocked, :any?).and_return true
      @b.stub(:type).and_return('OdBook')
    
      render
      # content(:menu).should == 'bonjour'
      list_icons = content(:menu).all('img')
      list_icons.should have(2).elements
      list_icons[1][:src].should == '/assets/icones/verrouiller.png'
    
    end

  end




end
