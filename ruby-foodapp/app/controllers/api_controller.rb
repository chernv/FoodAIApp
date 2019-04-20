class APIController < ApplicationController
  before_filter :set_current_user, :authenticate_user!

  def show
    render json: current_user
  end
  def update
    current_user.update api_params

    head :no_content
  end
  
  def process_image
    @food_image = current_user.food_images.create(food_image_params)
  end

  def index_img
    @food_images = current_user.food_images.all
    respond_to do |format|
       format.json { render :json => 
        @food_images.to_json(:only => 
          [:id, :description, :date, :foodimg, :categories, :foodtypes], :methods => [:img_url]) }
     end
  end
  
  def show_img
    @food_image = current_user.food_images.find(params[:id])
    render json: @food_image
  end

  def create_img
    @food_image = current_user.food_images.create(food_image_params)
    image = Paperclip.io_adapters.for(food_image_params[:foodimg]) 
    @food_image.foodimg = image
    @food_image.foodimg_file_name = params[:foodimg_file_name]
    # logger.warn "Url: #{@food_image.foodimg.url.inspect}"
    response = RestClient.post('https://peaceful-peak-78560.herokuapp.com/api/mnist', 
      {:url => @food_image.foodimg.url}.to_json, {content_type: :json, accept: :json} )
    # logger.warn "Response: #{response.inspect}"    
    desc_items = (JSON.parse response)["results"]
    # logger.warn "desc_items: #{desc_items.inspect}"        
    @food_image.categories = desc_items[0]
    @food_image.foodtypes = desc_items[1]
    @food_image.save
    # desc = ""
    # desc_items.each do |x|
    #   desc += (x[0] + "  " + x[1].to_s + "\n")
    # end
    # @food_image.description = desc
    # render json: @food_image.to_json(:only => [:id, :description, :date, :foodimg], :methods => [:img_url]) }
    respond_to do |format|
      format.json  { render :json => @food_image, :methods => :img_url}
    end
    # @food_image.save
    # current_user.food_images.save
      #   # redirect_to @food_image
      #
      # else
      #   render 'new'
      # end
  end
  def new_img
    @food_image = current_user.food_images.new
  end
  def edit_img
    @food_image = current_user.food_images.find(params[:id])
  end
  def update_img
    @food_image = current_user.food_images.find(params[:id])
    if @afood_image.update(food_image_params)
      redirect_to @food_image
    else
      render 'edit'
    end
  end
  def destroy_img
    @food_image = current_user.food_images.find(params[:id])
    @food_image.destroy
   
    redirect_to food_image_path
  end
  private
    def api_params
      params.require(:api).permit(:email, :displayName, :avatar)
    end
    def food_image_params
      params.permit(:description, :date, :foodimg, :foodimg_file_name)
    end  
end