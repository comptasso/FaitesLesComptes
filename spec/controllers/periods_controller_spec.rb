# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe PeriodsController do



  context 'testing with 2 periods how to change form one to another period' do
     include SpecControllerHelper

    before(:each) do
      minimal_instances
      @p2 = mock_model(Period, start_date:@p.start_date.years_since(1),
        close_date:@p.close_date.years_since(1), exercice:'exercice 2013')
      @b = mock_model(Book)
      Period.stub(:find).with(@p2.id.to_s).and_return @p2
      
    end

    describe 'GET change' do

      context 'en cas d erreur' do

      it 'remplit le flash alert' do
        Period.stub(:find).and_return(Exception)
        get :change, {:organism_id=>@o.id, :id=>@p2.id},  valid_session
        flash[:alert].should == 'L\'exercice demandé n\'a pas été trouvé. Retour à l\'affichage de l\'organisme'
      end


      it 'renvoie vers organism_url en cas d erreur' do
        Period.stub(:find).and_return(Exception)
        get :change, {:organism_id=>@o.id, :id=>@p2.id},  valid_session
        response.should redirect_to(organism_url(@o))
      end

      end

      # HTTP_REFERER sert à résourdre la question du lien vers back
      it "should change session[:period]"  do
        request.env["HTTP_REFERER"]=organisms_url
        get :change, {:organism_id=>@o.id, :id=>@p2.id},  valid_session
        session[:period].should == @p2.id
      end

      it "should render the right template"  do
        request.env["HTTP_REFERER"]=organisms_url
        get :change, {:organism_id=>@o.id, :id=>@p2.id},  valid_session
        response.should redirect_to organisms_url
      end

      context 'with an HTTP REFERER with an and mois params' do

        before(:each) do
          request.env["HTTP_REFERER"] = 'http://localhost:3000/books/13/lines?an=2012&mois=04'
          @p2.stub(:include_month?).with('04').and_return true
          @p2.stub(:find_first_month).with('04').and_return MonthYear.from_date(Date.civil(2013,04))
        end

        it 'should change period' do
          get :change, {:organism_id=>@o.id, :id=>@p2.id},   valid_session
          session[:period].should == @p2.id 
        end

        it 'should redirect to next year lines' do
          get :change, {:organism_id=>@o.id, :id=>@p2.id}, valid_session
          response.should redirect_to 'http://localhost:3000/books/13/lines?an=2013&mois=04'
        end

        context 'lorsque le mois n existe pas' do
          before(:each) do
            @p2.stub(:include_month?).with('04').and_return false
            @p2.stub(:guess_month).and_return double(MonthYear, :year=>2013, month:12)
          end
          it 'crée un flash alert' do
            get :change, {:organism_id=>@o.id, :id=>@p2.id},   valid_session 
            flash[:alert].should == 'Le mois demandé n\'existe pas pour cet exercice, affichage d\'un autre mois'
          end
          it 'demande guess_month à period' do
            @p2.should_receive(:guess_month).and_return(double(MonthYear, :year=>2013, month:12))
            get :change, {:organism_id=>@o.id, :id=>@p2.id},   valid_session
          end
        end



      end


 


    end
  end
end

