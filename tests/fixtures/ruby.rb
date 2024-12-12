class VehiclesController < ApplicationController
  # Vehicles allow for the transport of things

  def create
    @vehicle = Vehicle.create(vehicle_params)
    render json: @vehicle.to_json
  end

  def index
    @vehicles = Vehicle.all
    render json: @vehicles.to_json
  end

  def show
    @vehicle = Vehicle.find(params[:id])
    render json: @vehicle.to_json
  end

  def update
    @vehicle = Vehicle.find(params[:id])

    if @vehicle.update(vehicle_params)
      render json: @vehicle.to_json
    end
  end

  private
  def vehicle_params
    params.require(:vehicle).permit(:name, :description, :price)
  end

end

class VehiclesControllerrrrr < ApplicationController
  # Vehicles tend to have wheeeeeeeeeeeeeeeeeels

  def create
    @vehicle = Vehicle.create(vehicle_params)
    render json: @vehicle.to_json
  end

  def index
    @vehicles = Vehicle.all
    render json: @vehicles.to_json
  end

  def show
    @vehicle = Vehicle.find(params[:id])
    render json: @vehicle.to_json
  end

  def update
    @vehicle = Vehicle.find(params[:id])

    if @vehicle.update(vehicle_params)
      render json: @vehicle.to_json
    end
  end

  private
  def vehicle_params
    params.require(:vehicle).permit(:name, :description, :price)
  end

end

