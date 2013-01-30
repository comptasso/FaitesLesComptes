# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/rooms/index'  do
include JcCapybara

  let(:o) {mock_model(Organism, :title=>'Organisme Test')}
  let(:r1) {mock_model(Room, :organism=>o, database_name:'db1',
      :relative_version=>:same_migration,
      'late?'=>false, 'advanced?'=>false,  'no_base?'=>false)}
  let(:r2) {mock_model(Room, :organism=>o, database_name:'db2')}


  before(:each) do
    @rooms = [r1, r2]
    r2.stub(:relative_version).and_return(:same_migration)
    r2.stub('late?').and_return false
     r2.stub('advanced?').and_return false
    r2.stub('no_base?').and_return false
  end

  it 'le titre h3 est Liste des bases' do
    render
    page.find('h3').text.should == 'Liste des bases'
  end

  it 'afficher la table des bases' do
    render
    page.all('tbody tr' ).should have(2).rows
  end

  context 'avec une base qui est late' do

    it 'rend une action migrate' do
      r2.stub(:relative_version).and_return(:late_migration)
      r2.stub('late?').and_return true
      r2.should be_late
      render
      page.find('img:last')[:src].should have_content('migrer.png')
      page.find('tbody tr:last a')[:href].should == migrate_admin_room_path(r2)
      page.find('tbody tr:last a')['data-method'].should == 'post'
    end
    
  end

  context 'avec une base qui manque' do

    it 'rend une action destroy' do
      r2.stub('no_base?').and_return(true)
      render
      page.find('img:last')[:src].should have_content('supprimer.png')
      page.find('tbody tr:last a')[:href].should == migrate_admin_room_path(r2)
      page.find('tbody tr:last a')['data-method'].should == 'delete'
    end
  end

  context 'avec une base en avance' do
    it 'rend un feu rouge' do
      r2.stub('advanced?').and_return(true)
      render
      page.find('img:last')[:src].should have_content('traffic-light-red.png') 
    end
  end

  

end