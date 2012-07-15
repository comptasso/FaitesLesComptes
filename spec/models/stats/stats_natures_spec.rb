# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Stats::StatsNatures do
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

  describe 'construction des statistiques ' do
    let(:n1) {mock_model(Nature, income_outcome:true, name:'Recette1')}
     let(:n2) {mock_model(Nature, income_outcome:false, name:'Depense1')}
      let(:n3) {mock_model(Nature, income_outcome:true, name:'Recette2')}
      let(:n4){mock_model(Nature, income_outcome:false, name:'ARecette2')}
      let(:a) {double(Arel)}

     
    before(:each) do
      p.stub(:natures).and_return a
      a.stub(:all).and_return [n1,n2,n3,n4]
      [n1,n2,n3,n4].each do |n|
        n.stub(:stat_with_cumul).and_return(1.upto(12).collect {|i| i} + [78])
       end

    end
  
  it 'les natures doivent être classées par ordre recettes puis dépenses et par ordre alpha' do
    a.should_receive(:order).with('income_outcome DESC', 'name ASC').and_return([n1, n3, n4, n2])
    @stats_natures.lines.collect {|l| l[0] }.should == %w(Recette1 Recette2 ARecette2 Depense1)
  end
  


  describe 'restitution des stats' do
    before(:each) do
      p.stub_chain(:natures, :order).and_return([n1, n3, n2, n4])
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
  end


end

  describe 'avec un filtre' do

    let(:d) {mock_model(Destination)}

    it 'créationd de stats_natures accepte un filtre'  do
      @sn = Stats::StatsNatures.new(p, d.id)
      @sn.should be_an_instance_of(Stats::StatsNatures)
    end

    context 'un stats_natures avec filtre' do

    let(:n1) {mock_model(Nature, income_outcome:true, name:'Recette1')}

    before(:each) do
      @sn = Stats::StatsNatures.new(p, d.id)
       p.stub_chain(:natures, :order).and_return [n1] 
    end 
    it 'appelle stat_with_cumul avec d.id comme argument' do
      n1.should_receive(:stat_with_cumul).with(d.id).and_return 1.upto(13).collect {|i| i }
      @sn.lines 
    end

    end


  end
end 