class BookingsController < ApplicationController
  before_action :require_login
  def index
    bookings_scope = current_user.bookings
    if bookings_scope.empty?
      flash[:notice] = "No Bookings Found"
      render :new
      return
    end
    @pagy, @bookings = pagy(bookings_scope.order(created_at: :desc), limit: 2)
  end
  def show
    puts "--- Entered BOOKINGS ##{__method__.to_s.upcase} ---"
    puts "Params: #{params.inspect}"
    @booking = current_user.bookings.find(params[:id])
  end
  def new
    puts "--- Entered BOOKINGS ##{__method__.to_s.upcase} ---"
    puts "Params: #{params.inspect}"

    @show = Show.find(params[:show_id] || params[:show])

    booked_seats = BookingSeat.joins(:booking).where(show_id: @show.id).where(bookings: { status: 'confirmed' }).pluck(:seat_id)

    @seats = @show.hall.seats.where.not(id: booked_seats).order(:row, :seat_number)
    @booking = Booking.new
  end

  def create
    @show = Show.find(params[:show_id])

    if params[:seat_ids].blank?
      flash.now[:alert] = "Please select at least one seat."
      load_available_seats
      @booking = Booking.new
      render :new and return
    end

    seat_ids = params[:seat_ids].map(&:to_i)

    begin
      ActiveRecord::Base.transaction do
        locked_seats = Seat.where(id: seat_ids).lock.to_a

        if locked_seats.count != seat_ids.count
          raise ActiveRecord::RecordInvalid.new("One or more selected seats do not exist")
        end

        already_booked = BookingSeat.joins(:booking)
                                    .where(show_id: @show.id, seat_id: seat_ids)
                                    .where(bookings: { status: ['confirmed', 'pending'] })
                                    .exists?

        if already_booked
          raise ActiveRecord::RecordInvalid.new("One or more selected seats are no longer available")
        end

        @booking = current_user.bookings.create!(
          status: 'confirmed',
          show_id: @show.id
        )

        booking_seat_records = seat_ids.map do |seat_id|
          {
            booking_id: @booking.id,
            seat_id: seat_id,
            show_id: @show.id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        BookingSeat.insert_all(booking_seat_records)

        @success_redirect = booking_path(@booking)
      end

      redirect_to @success_redirect

    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
      redirect_to new_booking_path(show_id: @show.id)

    rescue ActiveRecord::RecordNotUnique => e
      flash[:error] = "One or more seats have already been booked."
      redirect_to new_booking_path(show_id: @show.id)

    rescue ActiveRecord::StatementInvalid => e
      flash[:error] = "Booking failed. Please try again."
      redirect_to new_booking_path(show_id: @show.id)
    end
  end

  def cancel
    @booking = current_user.bookings.find(params[:id])
    if @booking.update(status: :cancelled)
      flash[:notice] = "booking cancelled"
    else
      flash[:notice] = "booking not cancelled"
    end
    redirect_to bookings_path(@booking)
  end

  private

  def load_available_seats
    booked_seats = BookingSeat.joins(:booking)
                              .where(show_id: @show.id)
                              .where(bookings: { status: ['confirmed', 'pending'] })
                              .pluck(:seat_id)

    @seats = @show.hall.seats.where.not(id: booked_seats).order(:row, :seat_number)
  end

end
