# coding: utf-8

require 'spec_helper' 

describe Compta::MonthlyLedger do

  let(:p) {mock_model(Period)}
  let(:my) {MonthYear.from_date(Date.today)}
  let(:b1) {mock_model(Book,  :abbreviation=>'VE')}
  let(:b2) {mock_model(Book,  :abbreviation=>'OD')}


  it 'on peut construire un MonthlyLedger' do
    Compta::MonthlyLedger.new(p, my).should be_an_instance_of(Compta::MonthlyLedger)
  end

  describe 'lines' do

    before(:each) do
      p.stub(:books).and_return([b1, b2])
     [b1, b2].each {|b| b.stub_chain(:compta_lines, :mois).and_return(1.upto(10).
           map {double(ComptaLine, :debit=>3, :credit=>0)}) }
     Extract::Monthly.any_instance.stub(:total_debit).and_return 101
     Extract::Monthly.any_instance.stub(:total_credit).and_return 99
     @ml = Compta::MonthlyLedger.new(p, my)
     @mls = @ml.send(:lines)

    end
    it 'construit un tableau de lignes de hash' do
      @mls.should be_an(Array)
      @mls.each do |l|
        l.should be_an(Hash)
      end
    end

    it 'une ligne est constituée d un titre, description, total_debit, total_credit' do
      l = @mls.second
      l[:mois].should == ''
      l[:abbreviation].should == b2.abbreviation
      l[:debit].should == 101
      l[:credit].should == 99
    #  l[:title].should == 'bonjour' #b2.title
    end

    it 'sait faire sa ligne de titre' do
      @ml.send(:title_line)[:mois].should == "Mois de #{my.to_format('%B %Y')}"
    end

    it 'sait fournir sa ligne de total' do
      tl = @ml.send(:total_line)
      tl[:debit].should == 202
      tl[:credit].should == 198
    end
  end

  describe 'lines with _total' do

    before(:each) do
      @ml = Compta::MonthlyLedger.new(p, my)
      @ml.stub(:lines).and_return [['ligne 1'], ['ligne 2']]
    end

    it 'encadre les ligne par une ligne de titre et une de total' do
      @ml.stub(:title_line).and_return 'la ligne de titre'
      @ml.stub(:total_line).and_return 'la ligne de total'
      @ml.stub(:lines).and_return ['ligne 1', 'ligne 2']
      @ml.lines_with_total.should == ['la ligne de titre', 'ligne 1', 'ligne 2', 'la ligne de total']
    end


  end


end
