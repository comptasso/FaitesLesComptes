# coding: utf-8

# coding: utf-8

require 'spec_helper'

describe "cash_lines/index" do
  include JcCapybara

  let(:o) {mock_model(Organism, title: 'spec cd')}
  let(:p) {mock_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)}
  let(:c) {mock_model(Cash, name: 'Magasin')}
  let(:cc1) {mock_model(CashControl, date:1.week.ago, amount:10.52)}
  let(:cc2) {mock_model(CashControl, date:Date.today, amount:99.08)}
#  let(:n) {mock_model(Nature, :name=>'achat de marchandises')}
#  let(:cl1) { mock_model(Line, :line_date=>Date.today, :narration=>'test', :debit=>'45', :nature_id=>n.id)}
#  let(:cl2) {mock_model(Line, :line_date=>Date.today, :narration=>'autre ligne', :debit=>'54', :nature_id=>n.id)}


  before(:each) do
    assign(:organism, o)
    assign(:period, p)
    assign(:cash, c)
    assign(:cash_controls, [cc1,cc2])

    p.stub(:list_months).and_return %w(jan fév mar avr mai jui jui aou sept oct nov déc)

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
        row.find("td:last").all('img').first[:src].should == '/assets/icones/lock.png'
      end
    end

    it 'affiche l ecart de caisse' 
  end

  context 'avec un cash_control locked' do
    before(:each) do
       cc1.stub(:locked?).and_return(true)
       render
    end

    it 'une cash line locked n a pas d icone pour lock' do
      page.find("tbody tr:first td:last").should_not have_icon('lock.png')
      page.find("tbody tr:last td:last").should have_icon('lock.png')
    end
  end



end

