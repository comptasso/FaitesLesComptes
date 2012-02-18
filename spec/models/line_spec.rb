# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Line do
  
  let(:o) {stub_model(Organism, title: 'test_line')}
  let(:ib) {stub_model(IncomeBook, :organism_id=>o.id)}
  let(:ob) {stub_model(OutcomeBook, :organism_id=>o.id)}
  let(:n) {mock_model(Nature)}

  before(:each) do
    # la somme de 0 à 9 est égale à 45
    10.times {|t| Line.create!(:book_id=>ib.id, :line_date=>Date.civil(2012,01,t+2), :credit=>2*t , :nature_id=>n.id) }
    10.times {|t| Line.create(:book_id=>ob.id, :line_date=>Date.civil(2012,01,t+2), :debit=>t , :nature_id=>n.id) }
    10.times {|t| Line.create(:book_id=>ib.id, :line_date=>Date.civil(2012,02,t+2), :credit=>3*t , :nature_id=>n.id) }
    10.times {|t| Line.create(:book_id=>ob.id, :line_date=>Date.civil(2012,02,t+2), :debit=>2*t , :nature_id=>n.id) }
    10.times {|t| Line.create(:book_id=>ib.id, :line_date=>Date.civil(2012,03,t+2), :credit=>4*t , :nature_id=>n.id) }
    10.times {|t| Line.create(:book_id=>ob.id, :line_date=>Date.civil(2012,04,t+2), :debit=>5*t , :nature_id=>n.id) }

  end
  context 'verification que les lignes sont bien là' do

    it "vérif qu on a bien les lignes" do
      Line.count.should == 60
      end

      it 'income and outcomme should each have 30 lines' do
          ib.lines.should have(30).elements
        ob.lines.should have(30).elements
      end

    it "scope month return the right number of lines" do
      Line.month('01-2012').should have(20).elements
    end
  end

  it "give a monthly sold" do
    Line.monthly_sold('01-2012').should == 45
    Line.monthly_sold('02-2012').should == 45
    Line.monthly_sold('03-2012').should == 180
    Line.monthly_sold('04-2012').should == -225
  end
end

