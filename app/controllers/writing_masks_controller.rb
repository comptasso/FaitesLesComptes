class WritingMasksController < ApplicationController
  
  def new
    @mask = @organism.masks.find(params[:mask_id])
    render :text=>"je suis dans new mask inspect : #{@mask.title}"
  end
end
