# coding: utf-8

# coding: utf-8

require 'spec_helper'

#RSpec.configure do |c|
#  c.filter = {:wip=>true}
#end


describe "cash_controls/index" do
  include JcCapybara

  let(:o) {mock_model(Organism, title: 'spec cd')} 
  let(:p) {mock_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)}
  let(:c) {mock_model(Cash, name: 'Magasin')}
  let(:cc1) {mock_model(CashControl, date:1.week.ago.to_date, amount:10.52, 
      cash_id:c.id, locked?:false, cash:c, difference:0, cash_sold:10.52)}
  let(:cc2) {mock_model(CashControl, date:Date.today, amount:99.08, 
      cash_id:c.id, locked?:false, cash:c, difference:-2.92, cash_sold:102)} 
  
#  it 'current_page' , :wip=>true do
#      render
#      current_page?(:mois=> 2).should == true
#    end


  before(:each) do
    assign(:organism, o)
    assign(:period, p)
    assign(:cash, c)
    assign(:cash_controls, [cc1,cc2])
    p.stub(:list_months).and_return ListMonths.new(p.start_date, p.close_date)
#    c.stub(:sold).with(Date.today).and_return(102)
#    c.stub(:sold).with(1.week.ago.to_date).and_return(10.52)
    view.stub("current_page?").and_return false
  end


  describe "controle du corps" do

    before(:each) do
      render
    end

    it "affiche le titre de la page avec le nom de la caisse" do
      page.find('h3').should have_content "Liste des contrôles : Magasin"
    end

    it "affiche la table des controles de caisse" do
      assert_select "table tbody", count: 1
    end

    it "affiche les lignes (ici deux)" do
      assert_select "tbody tr", count: 2
    end

    it 'chaque ligne a deux icones (edit et lock)' do
      page.all("tbody tr").each do |row|
        row.find("td:last").all('img').first[:src].should == '/assets/icones/modifier.png'
        row.find("td:last").all('img').last[:src].should == '/assets/icones/verrouiller.png'
      end
    end
   

    it 'affiche l ecart de caisse'  
  end

  context 'avec un cash_control locked' do
    before(:each) do
       cc1.stub(:locked?).and_return(true)
       assign(:cash_controls, [cc1,cc2])
       render
    end

    it 'une cash line locked n a pas d icone pour lock' do
      page.find("tbody tr:first td:last").should_not have_icon('verrouiller')
      page.find("tbody tr:last td:last").should have_icon('verrouiller')
    end
  end



end

