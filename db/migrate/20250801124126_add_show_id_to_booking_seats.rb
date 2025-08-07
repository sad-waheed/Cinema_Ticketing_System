class AddShowIdToBookingSeats < ActiveRecord::Migration[8.0]
  def change
    add_reference :booking_seats, :show, null: false, foreign_key: true

    # Remove the old unique index (booking_id, seat_id)
    remove_index :booking_seats, column: [:booking_id, :seat_id]

    # Add a new unique index on [:show_id, :seat_id] to prevent double bookings of same seat for a show
    add_index :booking_seats, [:show_id, :seat_id], unique: true
  end
end
