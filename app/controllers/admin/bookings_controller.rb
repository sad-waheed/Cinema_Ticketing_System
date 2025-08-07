# frozen_string_literal: true
class Admin::BookingsController < ApplicationController
  before_action :require_admin_login

=begin
  def show
    @booking = Booking.includes(:booking_seats).find(params[:id])
    @booking_seats = @booking.booking_seats
    @show = Show.find(@booking.show_id)
    @hall = Hall.find(@show.hall_id)
    @movie = Movie.find(@show.movie_id)
    @user = User.find(@booking.user_id)
  end

=end
  def destroy
    @booking = Booking.find(params[:id])
    @show = Show.find(@booking.show_id)
    if @booking.destroy
      flash[:notice] = "Booking deleted"
      redirect_to admin_show_path(@show)
    else
      flash[:notice] = "Booking not deleted"
      render :new
    end
  end
end
