# frozen_string_literal: true
class Admin::HallsController < ApplicationController
  def new
    @hall = Hall.new
  end
  def create
    @hall = Hall.where(name: params.require(:name))
    if @hall.nil?
      flash[:notice] = "Hall already exists"
      render action: :new
      return
    end
    @hall = Hall.new(name: params.require(:name))

    if @hall.save
      seats_by_row = params[:seats] || {}
      seat_records = []

      seats_by_row.each do |row_letter, seat_count|
        seat_count.to_i.times do
          seat_records <<{
            hall_id: @hall.id,
            row: row_letter,
            seat_number: i+1,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
      end
      seat.insert_all(seat_records)
      @hall.update!(seats_count: @hall.seats.count)
      flash[:success] = "Hall and seats created successfully"
      redirect_to admin_halls_path
    else
      flash[:error] = "Failed to create hall"
      render :new
    end

  end

  def destroy
    hall = Hall.find(params[:id])
    if hall.destroy
      flash[:notice] = "Hall deleted!"
      redirect_to admin_halls_path
    else
      flash[:error] = "Failed to delete hall"
      redirect_to admin_halls_path
    end
  end
  def index
    hall_scope = Hall.all
    @pagy, @halls = pagy(hall_scope.order(:created_at), limit: 2)
    x = 2
  end
  def show
    @hall = Hall.includes(:seats).find(params[:id])
    @seats = @hall.seats
    if @hall.nil?
      flash[:notice] = "Error in getting hall"
      render :new
    end
  end
end
