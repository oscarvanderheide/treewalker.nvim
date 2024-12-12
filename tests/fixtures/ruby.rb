class ProductsController < ApplicationController
  # before_action :authenticate_user!

  def create
    @product = Product.create(product_params)
    render json: @product.to_json
  end

  def index
    @products = Product.all
    render json: @products.to_json
  end

  def show
    @product = Product.find(params[:id])
    render json: @product.to_json
  end

  def update
    @product = Product.find(params[:id])

    if @product.update(product_params)
      render json: @product.to_json
    end
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :price)
  end

end

class ProductsControllerrrrr < ApplicationController
  # before_action :authenticate_user!

  def create
    @product = Product.create(product_params)
    render json: @product.to_json
  end

  def index
    @products = Product.all
    render json: @products.to_json
  end

  def show
    @product = Product.find(params[:id])
    render json: @product.to_json
  end

  def update
    @product = Product.find(params[:id])

    if @product.update(product_params)
      render json: @product.to_json
    end
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :price)
  end

end

