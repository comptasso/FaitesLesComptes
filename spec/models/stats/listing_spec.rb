# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Stats::Listing do
   def stat_lines
    1.upto(200).collect {|i| ['ligne', 1, 2, 3, 6]}
  end

   def title
     ['LIGNE', 'VAL',  'VAL', 'VAL', 'TOTAUX']
   end

  before(:each) do
    @listing = Stats::Listing.new(title, stat_lines)
  end

  it "listing est créé" do
    @listing.should be_an_instance_of(Stats::Listing) 
  end

  it 'listing a des lignes' do
    @listing.should have(200).lines
  end

   it 'on peut fixer le nombre de lignes par page' do
     @listing.nb_per_page = 20
     @listing.nb_per_page.should == 20
   end

   it 'le nombre de lignes par défaut est de 22' do
     @listing.nb_per_page.should == 22
   end

   it 'le listing a donc 200/22 plus une page' do
     @listing.pages.size.should == 1 + (200/22)
   end

   it 'les totaux de la première page valent 22,...' do
     @listing.pages[0].total_page_line.should == ['Total page', 22, 44, 66, 132]
     @listing.pages[0].to_report_line == ['A reporter', 22, 44, 66, 132]
   end

   it 'les reports de la page 2' do
     @listing.pages[1].report_line.should == ['Reports', 22,44,66,132]
   end

   it 'le total général de la denière page' do
     @listing.pages.last.to_report_line.should == ['Total général', 200 ,400,600,1200]
   end

end

