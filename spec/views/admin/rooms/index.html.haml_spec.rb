# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/rooms/index'  do
include JcCapybara

  let(:o) {mock_model(Organism, :title=>'Organisme Test')}
  let(:r1) {mock_model(Room, :organism=>o, db_filename:'db1.sqlite3',
      :relative_version=>:same_migration, last_archive:nil,
      'late?'=>false, 'advanced?'=>false,  'no_base?'=>false, 'up_to_date?'=>true)}
  let(:r2) {mock_model(Room, :organism=>o, 
      db_filename:'db2.sqlite3',
    last_archive:mock_model(Archive, :created_at=>Date.today))}


  before(:each) do
    @rooms = [r1, r2]
    view.stub(:abc).and_return(ActiveRecord::Base.connection_config)
    r2.stub(:relative_version).and_return(:same_migration)
    r2.stub('up_to_date?').and_return true
    r2.stub('late?').and_return false
     r2.stub('advanced?').and_return false  
    r2.stub('no_base?').and_return false
  end

  it 'le titre h3 est Liste des organismes' do
    render
    page.find('h3').text.should == 'Liste des organismes'
  end

  it 'afficher la table des bases' do 
    render
    page.all('tbody tr' ).should have(2).rows
  end

  describe 'les actions' do
    it 'rend 3 icones dans la dernière colonne' do
      render
      page.all('tr:last td:last img').should have(3).icons
    end

    it 'mais n en rend pas si la room  n est pas à jour' do
      r2.stub('up_to_date?').and_return false
      render
      page.all('tr:last td:last img').should have(0).icons
    end
  end

  context 'avec une base qui est late' do

    it 'rend une action migrate' do
      r2.stub(:relative_version).and_return(:late_migration)
      r2.stub('late?').and_return true
      r2.should be_late
      render
      page.find('tr:last td:nth-child(5) img')[:src].should have_content('migrer.png')
      page.find('tr:last td:nth-child(5) a')[:href].should == migrate_admin_room_path(r2)
      page.find('tr:last td:nth-child(5) a')['data-method'].should == 'post'
    end
    
  end

  context 'avec une base qui manque' do 

    it 'rend une action destroy' do
      r2.stub('no_base?').and_return(true)
      render
      page.find('tr:last td:nth-child(5) img')[:src].should have_content('supprimer.png')
      page.find('tr:last td:nth-child(5) a')[:href].should == admin_room_path(r2)
      page.find('tr:last td:nth-child(5) a')['data-method'].should == 'delete'
    end
  end

  context 'avec une base en avance' do
    it 'rend un feu rouge' do
      r2.stub('advanced?').and_return(true)
      render
      page.find('tr:last td:nth-child(5)').should have_icon('traffic-light-red')
    end
  end

  

end