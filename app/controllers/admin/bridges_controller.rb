class Admin::BridgesController < Admin::ApplicationController
  def show
    @bridge = @organism.bridge
  end
  
  def edit
    @bridge = @organism.bridge
  end
end
