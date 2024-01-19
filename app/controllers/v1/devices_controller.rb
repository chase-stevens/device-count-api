class V1::DevicesController < ApplicationController
  def record_count
    @device = Device.find(params[:id])

    if @device
      @device.update(parse_readings)
    else
      @device = Device.create(uuid: params[:id], readings: parse_readings)
    end

    render json: { status: 202 }
  end

  def latest_timestamp
    @device = Device.find(params[:uuid])

    if @device
      render json: { latest_timestamp: @device.latest_timestamp }
    else
      render json: { status: 404 }
    end
  end

  def cumulative_count
    @device = Device.find(params[:uuid])

    if @device
      render json: { cumulative_count: @device.cumulative_count }
    else
      render json: { status: 404 }
    end
  end

  private

  def parse_readings
    readings_arr = []
    params[:readings].each do |reading|
      reading_obj = { timestamp: reading[:timestamp], count: reading[:count] }
      next if readings_arr.include? reading_obj
      readings_arr << reading_obj
    end
    readings_arr
  end
end
