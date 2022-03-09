require "json"
require "open-uri"

class RestaurantsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def new
    @restaurant = Restaurant.new
  end

  def create
    raise
    @restaurant =  Restaurant.new(restaurant_strong)
    @dishes = params[:dish_restaurants][:dishes].reject(&:empty?)
    @restaurant.save
    @dishes.each do |dish_id|
      dish = Dish.find(dish_id.to_i)
      DishRestaurant.create(dish: dish, restaurant: @restaurant)
    end
    redirect_to restaurants_path
  end

  def edit
    @restaurant = Restaurant.find(params[:id])
  end

  def update
    @restaurant = Restaurant.find(params[:id])
    @restaurant.update(restaurant_strong)
    redirect_to restaurants_path
  end

  def index
    @restaurants = Restaurant.all
    @dishrestaurants = DishRestaurant.all
    @timenow = Time.now
    @timenow = @timenow.hour
    @daynow = Time.now
    @daynow = @daynow.wday - 1
    # !! THIS LOGIC MUST BE CHANGED ONCE WE HAVE A LINKED RESTAURANTS_DISH FROM THE JOIN TABLE !!

    if params[:location].present?
      @restaurants = Restaurant.all.near(params[:location], 20)
    end

    # API Call
    # search = "ramen"
    # url = 'https://api.spoonacular.com/food/products/search?query=ramen&apiKey=API-KEY'
    # user_serialized = URI.open(url).read
    # @gituser = JSON.parse(user_serialized)
  end

  def favorite
    @restaurant = Restaurant.find params[:restaurant_id]
    FavoriteRestaurant.create(user: current_user, restaurant: @restaurant)
    redirect_to restaurants_path, notice: 'Added restaurant to favorites'
  end

  private

  def restaurant_strong
    params.require(:restaurant).permit(:name, :address, :website, :telephone, photos: [])
  end

end
