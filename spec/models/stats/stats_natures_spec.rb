# coding: utf-8

require "spec_helper"

RSpec.configure do |c|
 # c.filter = {wip:true} 
end

describe Stats::StatsNatures do
  include OrganismFixtureBis
  
  let(:p) {mock_model(Period, start_date:Date.today.beginning_of_year, end_date:Date.today.end_of_year)}
  
  
  before(:each) do
    p.stub(:list_months).and_return(ListMonths.new(Date.today.beginning_of_year, Date.today.end_of_year))
    @stats_natures = Stats::StatsNatures.new(p)
  end

  it "création de stats_natures demande un exercice" do
    @stats_natures.should be_an_instance_of(Stats::StatsNatures)
  end


  it "connait l exercice" do
    @stats_natures.period.should == p
  end

  it "contrôle de la ligne de titre" do
    y = Date.today.year.to_s[/\d\d$/]
    lt = ["Natures", "jan. #{y}", "fév. #{y}", "mar. #{y}",
      "avr. #{y}", "mai #{y}", "juin #{y}",
      "juil. #{y}", "août #{y}", "sept. #{y}",
      "oct. #{y}", "nov. #{y}", "déc. #{y}", 'Total']
    @stats_natures.title.should == lt
  end

  

  describe 'restitution des stats' do
    before(:each) do
      @stats_natures.stub(:lines).and_return [
        ['Recette1'] + 1.upto(12).collect {|i| i} + [78],
        ['Recette2'] + 1.upto(12).collect {|i| i} + [78],
        ['Depense1'] + 1.upto(12).collect {|i| i} + [78],
        ['Depense2'] + 1.upto(12).collect {|i| i} + [78]
        
      ]
    end

    it 'construit les lignes de statistiques' do
      @stats_natures.should have(4).lines
    end

    context 'vérification du contenu des lignes' do
      it 'est un array' do
          @stats_natures.lines.should be_an_instance_of(Array)
      end
      it 'chaque ligne de stat a 14 valeurs' do
          @stats_natures.lines.first.should have(14).elements
      end
      it 'la première colonne est le nom' do
          @stats_natures.lines.first.should == ['Recette1'] + 1.upto(12).collect {|i| i} + [1.upto(12).sum {|i| i}]
      end
       
    end

    it 'construit la ligne de total' do
        @stats_natures.totals.should == ['Totaux'] + 1.upto(12).collect {|i| 4*i} + [1.upto(12).sum {|i| 4*i}]
    end

    it 'peut produire un csv' do
      @stats_natures.to_csv.should == "Natures\tjan. 15\tfév. 15\tmar. 15\tavr. 15\tmai 15\tjuin 15\tjuil. 15\taoût 15\tsept. 15\toct. 15\tnov. 15\tdéc. 15\tTotal\nRecette1\t1,00\t2,00\t3,00\t4,00\t5,00\t6,00\t7,00\t8,00\t9,00\t10,00\t11,00\t12,00\t78,00\t\nRecette2\t1,00\t2,00\t3,00\t4,00\t5,00\t6,00\t7,00\t8,00\t9,00\t10,00\t11,00\t12,00\t78,00\t\nDepense1\t1,00\t2,00\t3,00\t4,00\t5,00\t6,00\t7,00\t8,00\t9,00\t10,00\t11,00\t12,00\t78,00\t\nDepense2\t1,00\t2,00\t3,00\t4,00\t5,00\t6,00\t7,00\t8,00\t9,00\t10,00\t11,00\t12,00\t78,00\t\nTotaux\t4,00\t8,00\t12,00\t16,00\t20,00\t24,00\t28,00\t32,00\t36,00\t40,00\t44,00\t48,00\t312,00\t\n"
    end

    # TODO ne pas oublier de tester le module Editions
    it 'peut produire un pdf' do
      Editions::Stats.should_receive(:new).with(p, @stats_natures)
      @stats_natures.to_pdf
    end
     
  end

  

  describe 'avec un filtre' do
    
    let(:d) {mock_model(Destination)}
       
    subject { Stats::StatsNatures.new(p, [d.id])}

    it 'créationd de stats_natures accepte un filtre'  do
      subject.should be_an_instance_of(Stats::StatsNatures)
    end
    
    it 'et le transmet à statistics pour obtenir les lines' do
      Nature.should_receive(:statistics).with(p, [d.id] )
      subject.lines
    end

    
  end
  
  context 'avec  l organisme de test', wip:true do
    
    before(:each) {use_test_organism}
    
    it 'peut créer l instance' do
      lambda {Stats::StatsNatures.new(@p)}.should_not raise_error
    end
    
    it 'peut créer un csv' do
      lambda {Stats::StatsNatures.new(@p).to_csv}.should_not raise_error
    end
    
    it 'peut créer un pdf' do
      lambda {Stats::StatsNatures.new(@p).to_pdf}.should_not raise_error
    end
    
    it 'et peut rendre le pdf' do
      lambda {Stats::StatsNatures.new(@p).to_pdf.render}.should_not raise_error
    end
    
    
  end
end 